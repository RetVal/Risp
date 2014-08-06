//
//  __RispLLVMFoundation.m
//  Risp
//
//  Created by closure on 6/10/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "__RispLLVMFoundation.h"
#include "RispLLVM.h"

namespace RispLLVM {
    class Selector {
    public:
        Selector() : _selector(nil) {
            
        }
        
        Selector(SEL sel) : _selector(sel) {
            if (!_methodSingature) {
                _methodSingature = [NSMethodSignature methodSignatureForSelector:_selector];
            }
        }
        
        Selector(int idx) : _selector(reinterpret_cast<SEL>(idx)) {
            
        }
        
        std::string getAsString() const {
            return std::string(sel_getName(_selector));
        }
    public:
        static inline RispLLVM::Selector getEmptyMarker() {
            return Selector(-1);
        }
        
        static inline RispLLVM::Selector getTombstoneMarker() {
            return Selector(-2);
        }
        
        bool operator==(RispLLVM::Selector RHS) const {
            return sel_isEqual(_selector, RHS._selector);
        }
        
        bool isNull() const {
            return _selector == nil || _selector == reinterpret_cast<SEL>(-1) || _selector == reinterpret_cast<SEL>(-2);
        }
        
        unsigned getNumArgs() const {
            if (isNull()) {
                return 0;
            }
            return (unsigned)[_methodSingature numberOfArguments] - 2; // self, _cmd
        }
    private:
        SEL _selector;
        NSMethodSignature *_methodSingature;
    };
    
    class IdentifierInfo {
        
    public:
        IdentifierInfo(StringRef name) : _name(name) {
            
        }
        
        ~IdentifierInfo() {
            
        }
        
        llvm::StringRef getName() const {
            return _name;
        }
        
    private:
        StringRef _name;
    };
}

/// Define DenseMapInfo so that Selectors can be used as keys in DenseMap and
/// DenseSets.
template <>
struct DenseMapInfo<RispLLVM::Selector> {
    static inline RispLLVM::Selector getEmptyKey() {
        return RispLLVM::Selector::getEmptyMarker();
    }
    static inline RispLLVM::Selector getTombstoneKey() {
        return RispLLVM::Selector::getTombstoneMarker();
    }
    
    static unsigned getHashValue(RispLLVM::Selector S) {
        return 0;
    }
    
    static bool isEqual(RispLLVM::Selector LHS, RispLLVM::Selector RHS) {
        return LHS == RHS;
    }
};

namespace LangAS {
    
    /// \brief Defines the set of possible language-specific address spaces.
    ///
    /// This uses a high starting offset so as not to conflict with any address
    /// space used by a target.
    enum ID {
        Offset = 0xFFFF00,
        
        opencl_global = Offset,
        opencl_local,
        opencl_constant,
        
        cuda_device,
        cuda_constant,
        cuda_shared,
        
        Last,
        Count = Last-Offset
    };
    
    /// The type of a lookup table which maps from language-specific address spaces
    /// to target-specific ones.
    typedef unsigned Map[Count];
    
}


//static llvm::IRBuilder<> _builder(llvm::getGlobalContext());
using namespace llvm;

typedef llvm::ArrayRef<llvm::Type*> TypeArray;

@interface __RispLLVMFoundation (Context)
- (llvm::LLVMContext *)llvmContext;
@end

@interface __RispLLVMObjcType () {
@private
    llvm::IntegerType *_intTy;
    llvm::IntegerType *_charTy;
    llvm::IntegerType *_int64Ty;
    llvm::IntegerType *_longTy;
    llvm::IntegerType *_unsignedIntTy;
    llvm::PointerType *_intptrTy;
    llvm::PointerType *_int8PtrTy;
    llvm::PointerType *_int8PtrPtrTy;
    
    llvm::PointerType *_idTy;
    llvm::PointerType *_selectorTy;
    llvm::Type *_voidTy;
    
    llvm::Type *_ivarOffsetVarTy;
    
//    llvm::StructType *_propertynfABITy;
//    llvm::StructType *_propertyListTy;
//    llvm::PointerType *_propertyListPtrTy;
//    llvm::StructType *_methodnfABITy;
//    llvm::StructType *_cachenfABITy;
//    llvm::PointerType *_cachenfABIPtrTy;
//    
//    llvm::StructType *_methodListnfABITy;
//    llvm::Type *_methodListnfABIPtrTy;
//    llvm::StructType *_protocolnfABITy;
//    llvm::Type *_protocolnfABIPtrTy;
//    llvm::StructType *_protocolListnfABITy;
//    llvm::Type *_protocolListnfABIPtrTy;
//    llvm::StructType *_classnfABITy;
//    llvm::Type *_classnfABIPtrTy;
//    llvm::StructType *_ivarnfABITy;
////    llvm::Type *_ivarnfABIPtrTy;
//    llvm::StructType *_ivarListnfABITy;
//    llvm::Type *_ivarListnfABIPtrTy;
//    llvm::StructType *_classRonfABITy;
//    llvm::Type *_impnfABITy;;
//    llvm::StructType *_categorynfABITy;
//    llvm::StructType *_messageRefTy;
//    llvm::Type *_messageRefPtrTy;
//    llvm::FunctionType *_messengerTy;
//    llvm::StructType *_superMessageRefTy;
//    llvm::Type *_superMessageRefPtrTy;
}
@end

@implementation __RispLLVMObjcType
+ (instancetype)helper {
    static dispatch_once_t onceToken;
    static __RispLLVMObjcType *objcType;
    dispatch_once(&onceToken, ^{
        objcType = [[__RispLLVMObjcType alloc] init];
    });
    return objcType;
}

- (Type *)llvmTypeFromObjectiveCType:(const char *)type {
#define IF_ISTYPE(t) if(strcmp(@encode(t), type) == 0)
#define INT_TYPE(t) IF_ISTYPE(t) return IntegerType::get(llvm::getGlobalContext(), sizeof(t) * CHAR_BIT)
#define PTR_TYPE(t) IF_ISTYPE(t) return PointerType::getUnqual([self charType])
    INT_TYPE(char);
    INT_TYPE(short);
    INT_TYPE(int);
    INT_TYPE(long);
    INT_TYPE(long long);
    INT_TYPE(unsigned char);
    INT_TYPE(unsigned short);
    INT_TYPE(unsigned int);
    INT_TYPE(unsigned long);
    INT_TYPE(unsigned long long);
    IF_ISTYPE(float) return Type::getFloatTy(llvm::getGlobalContext());
    IF_ISTYPE(double) return Type::getDoubleTy(llvm::getGlobalContext());
    IF_ISTYPE(void) return Type::getVoidTy(llvm::getGlobalContext());
    PTR_TYPE(char *);
    PTR_TYPE(id);
    PTR_TYPE(SEL);
    PTR_TYPE(Class);
    if(type[0] == '^') return PointerType::getUnqual([self charType]);
    
    return NULL;
#undef IF_ISTYPE
#undef INT_TYPE
#undef PTR_TYPE
}

- (instancetype)init {
    if (self = [super init]) {
        _intTy = llvm::IntegerType::get(llvm::getGlobalContext(), sizeof(int) * CHAR_BIT);
        _charTy = llvm::IntegerType::get(llvm::getGlobalContext(), CHAR_BIT);
        _intptrTy = llvm::IntegerType::getInt32PtrTy(llvm::getGlobalContext());
        _idTy = llvm::PointerType::getUnqual([self charType]);;
        _selectorTy = llvm::PointerType::getUnqual([self charType]);
        _int64Ty = llvm::IntegerType::get(llvm::getGlobalContext(), sizeof(int64_t) * CHAR_BIT);
        _longTy = llvm::IntegerType::get(llvm::getGlobalContext(), sizeof(long) * CHAR_BIT);
        _unsignedIntTy = llvm::IntegerType::get(llvm::getGlobalContext(), sizeof(unsigned int) * CHAR_BIT);
        _int8PtrTy = llvm::PointerType::getUnqual(llvm::IntegerType::get(llvm::getGlobalContext(), sizeof(int8_t) * CHAR_BIT));
        _int8PtrPtrTy = llvm::PointerType::getUnqual([self int8PtrType]);
        _voidTy = llvm::PointerType::getVoidTy(llvm::getGlobalContext());
        
        //amd64 _ivarOffsetVarTy = _uint
        _ivarOffsetVarTy = _longTy;
        
        // struct _prop_t {
        //   char *name;
        //   char *attributes;
        // }
        _propertyTy = llvm::StructType::create("struct._prop_t", _int8PtrTy, _int8PtrTy, nil);
        
        // struct _prop_list_t {
        //   uint32_t entsize;      // sizeof(struct _prop_t)
        //   uint32_t count_of_properties;
        //   struct _prop_t prop_list[count_of_properties];
        // }
        _propertyListTy = llvm::StructType::create("struct._prop_list_t", _intTy, _intTy, llvm::ArrayType::get(_propertyTy, 0), nil);
        _propertyListPtrTy = llvm::PointerType::getUnqual(_propertyListTy);
        
        // struct _objc_method {
        //   SEL _cmd;
        //   char *method_type;
        //   char *_imp;
        // }
        _methodnfABITy = llvm::StructType::create("struct._objc_method", _selectorTy, _int8PtrTy, _int8PtrTy, nil);
        
        _cacheTy = llvm::StructType::create(llvm::getGlobalContext(), "struct._objc_cache");
        _cachePtrTy = llvm::PointerType::getUnqual(_cacheTy);
        
        // struct _method_list_t {
        //   uint32_t entsize;  // sizeof(struct _objc_method)
        //   uint32_t method_count;
        //   struct _objc_method method_list[method_count];
        // }
        _methodListnfABITy = llvm::StructType::create("struct.__method_list_t", _intTy, _intTy, llvm::ArrayType::get(_methodnfABITy, 0), nil);
        _methodListnfABIPtrTy = llvm::PointerType::getUnqual(_methodListnfABITy);
        
        _protocolListnfABITy = llvm::StructType::create(llvm::getGlobalContext(), "struct._objc_protocol_list");
        
        // struct _protocol_t {
        //   id isa;  // NULL
        //   const char * const protocol_name;
        //   const struct _protocol_list_t * protocol_list; // super protocols
        //   const struct method_list_t * const instance_methods;
        //   const struct method_list_t * const class_methods;
        //   const struct method_list_t *optionalInstanceMethods;
        //   const struct method_list_t *optionalClassMethods;
        //   const struct _prop_list_t * properties;
        //   const uint32_t size;  // sizeof(struct _protocol_t)
        //   const uint32_t flags;  // = 0
        //   const char ** extendedMethodTypes;
        // }
        _protocolnfABITy = llvm::StructType::create("struct._protocol_t", _idTy, _int8PtrTy,
                                                    llvm::PointerType::getUnqual(_protocolListnfABITy),
                                                    _methodListnfABIPtrTy, _methodListnfABIPtrTy,
                                                    _methodListnfABIPtrTy, _methodListnfABIPtrTy,
                                                    _protocolListnfABIPtrTy, _intTy, _intTy,
                                                    _int8PtrPtrTy, nil);
        // struct _protocol_t*
        _protocolnfABIPtrTy = llvm::PointerType::getUnqual(_protocolnfABITy);
        
        // struct _protocol_list_t {
        //   long protocol_count;   // Note, this is 32/64 bit
        //   struct _protocol_t *[protocol_count];
        // }
        _protocolListnfABITy->setBody(_longTy, llvm::ArrayType::get(_protocolnfABIPtrTy, 0), nil);
        
        _protocolListnfABIPtrTy = llvm::PointerType::getUnqual(_protocolListnfABITy);
        
        // struct _ivar_t {
        //   unsigned [long] int *offset;  // pointer to ivar offset location
        //   char *name;
        //   char *type;
        //   uint32_t alignment;
        //   uint32_t size;
        // }
        _ivarnfABITy = llvm::StructType::create("struct._ivar_t", llvm::PointerType::getUnqual(_ivarOffsetVarTy), _int8PtrTy, _int8PtrTy, _intTy, _intTy, nil);
        
        // struct _ivar_list_t {
        //   uint32 entsize;  // sizeof(struct _ivar_t)
        //   uint32 count;
        //   struct _iver_t list[count];
        // }
        _ivarListnfABITy = llvm::StructType::create("struct._ivar_list_t", _intTy, _intTy, llvm::ArrayType::get(_ivarnfABITy, 0), nil);
        _ivarnfABIPtrTy = llvm::PointerType::getUnqual(_ivarnfABITy);
        
        // struct _class_ro_t {
        //   uint32_t const flags;
        //   uint32_t const instanceStart;
        //   uint32_t const instanceSize;
        //   uint32_t const reserved;  // only when building for 64bit targets
        //   const uint8_t * const ivarLayout;
        //   const char *const name;
        //   const struct _method_list_t * const baseMethods;
        //   const struct _objc_protocol_list *const baseProtocols;
        //   const struct _ivar_list_t *const ivars;
        //   const uint8_t * const weakIvarLayout;
        //   const struct _prop_list_t * const properties;
        // }
        _classRonfABITy = llvm::StructType::create("struct._class_ro_t",
                                                   _intTy, _intTy, _intTy, _int8PtrTy,
                                                   _int8PtrTy, _methodListnfABIPtrTy,
                                                   _protocolListnfABIPtrTy,
                                                   _ivarListnfABIPtrTy,
                                                   _int8PtrTy, _propertyListPtrTy, nil);
        // ImpnfABITy - LLVM for id (*)(id, SEL, ...)
        llvm::Type *params[] = {_idTy, _selectorTy};
        _impnfABITy = llvm::FunctionType::get(_idTy, params, false)->getPointerTo();
        // struct _class_t {
        //   struct _class_t *isa;
        //   struct _class_t * const superclass;
        //   void *cache;
        //   IMP *vtable;
        //   struct class_ro_t *ro;
        // }
        _classnfABITy = llvm::StructType::create(llvm::getGlobalContext(), "struct._class_t");
        _classnfABITy->setBody(llvm::PointerType::getUnqual(_classnfABITy),
                              llvm::PointerType::getUnqual(_classnfABITy),
                              _cachePtrTy,
                              llvm::PointerType::getUnqual(_impnfABITy),
                              llvm::PointerType::getUnqual(_classRonfABITy),
                              nil);
        // LLVM for struct _class_t *
        _classnfABIPtrTy = llvm::PointerType::getUnqual(_classnfABITy);
        // struct _category_t {
        //   const char * const name;
        //   struct _class_t *const cls;
        //   const struct _method_list_t * const instance_methods;
        //   const struct _method_list_t * const class_methods;
        //   const struct _protocol_list_t * const protocols;
        //   const struct _prop_list_t * const properties;
        // }
        _categorynfABITy = llvm::StructType::create("struct._category_t",
                                                    _int8PtrTy, _classnfABIPtrTy,
                                                    _methodListnfABIPtrTy,
                                                    _methodListnfABIPtrTy,
                                                    _protocolListnfABIPtrTy,
                                                    _propertyListPtrTy,
                                                    nil);
        
        // MessageRefTy - LLVM for:
        // struct _message_ref_t {
        //   IMP messenger;
        //   SEL name;
        // };
        _messageRefTy = llvm::StructType::create("struct._message_ref_t", _voidTy, _selectorTy, nil); // CGObjcMac.cpp - line 5440
        // MessageRefPtrTy - LLVM for struct _message_ref_t*
        _messageRefPtrTy = llvm::PointerType::getUnqual(_messageRefTy);
        // SuperMessageRefTy - LLVM for:
        // struct _super_message_ref_t {
        //   SUPER_IMP messenger;
        //   SEL name;
        // };
        _superMessageRefTy = llvm::StructType::create("struct._super_message_ref_t", _impnfABITy, _selectorTy, nil);
        _superMessageRefPtrTy = llvm::PointerType::getUnqual(_superMessageRefTy);
        
        _ehTypeTy = llvm::StructType::create("struct._objc_typeinfo", llvm::PointerType::getUnqual(_int8PtrTy), _int8PtrTy, _classnfABIPtrTy, nil);
        _ehTypePtrTy = llvm::PointerType::getUnqual(_ehTypeTy);
    }
    return self;
}

//- (llvm::Constant *)messageSendFn {
//    llvm::Type *params[] = {};
//    return [];
//}
@end


@interface __RispLLVMFoundation (TypeHelper)
- (llvm::IntegerType *)intType;
- (llvm::IntegerType *)charType;
- (llvm::PointerType *)intptrType;
- (llvm::IntegerType *)int64Type;
- (llvm::IntegerType *)longType;
- (llvm::PointerType *)idType;
- (llvm::PointerType *)selectorType;
- (llvm::Type *)voidType;
- (llvm::Type *)llvmTypeFromObjectiveCType:(const char *)type;
@end

@interface __RispLLVMFoundation (Value)
- (llvm::Value *)valueForPointer:(void *)ptr builder:(llvm::IRBuilder<> &)builder type:(llvm::Type *)type name:(const char *)name;
- (llvm::Value *)valueForSelector:(SEL)aSEL builder:(llvm::IRBuilder<> &)builder;
- (llvm::Value *)valueForClass:(Class)aClass builder:(llvm::IRBuilder<> &)builder;
@end

@interface __RispLLVMFoundation (Function)
- (llvm::Function *)msgSend;
@end

@interface __RispLLVMFoundation (Call)
- (llvm::Value *)msgSendToTarget:(id)target selector:(SEL)cmd arguments:(NSArray *)arguments;
- (llvm::Value *)msgSend:(llvm::Value *)target selector:(SEL)cmd arguments:(std::vector<Value *>)arguments;
@end

@interface __RispLLVMFoundation (Literal)
- (GlobalValue *)globalValue:(StringRef)name;
- (Constant *)emitObjCStringLiteral:(NSString *)string;
- (Constant *)emitConstantCStringLiteral:(const std::string &)string globalName:(const char *)globalName alignment:(unsigned)alignment;
@end

@interface __RispLLVMFoundation (Class)
- (std::string)objcClassSymbolPrefix;
- (std::string)metaClassSymbolPrefix;
- (llvm::GlobalVariable *)classGlobalWithName:(const std::string&)name isWeak:(BOOL)weak;
- (llvm::Value *)emitClassRefFromId:(RispLLVM::IdentifierInfo *)II isWeak:(BOOL)weak;
- (llvm::Value *)emitAutoreleasePoolClassRef;
- (llvm::Value *)emitClassNamed:(NSString *)name isWeak:(BOOL)weak;
- (llvm::Value *)emitSuperClassRef:(RispLLVM::IdentifierInfo *)II isWeak:(BOOL)weak;
- (llvm::Value *)emitMetaClassRef:(RispLLVM::IdentifierInfo *)II isWeak:(BOOL)weak;
- (llvm::Value *)classFromIdentifierInfo:(RispLLVM::IdentifierInfo *)II isWeak:(BOOL)weak;
@end

@interface __RispLLVMFoundation (Selector)
- (llvm::Value *)emitSelector:(RispLLVM::Selector)selector isValue:(BOOL)lval;
@end

@interface __RispLLVMFoundation (Helper)
+ (llvm::Constant *)constantGEP:(llvm::LLVMContext &)VMContext constant:(llvm::Constant *)c idx0:(unsigned)idx0 idx1:(unsigned)idx1;
@end

@interface __RispLLVMFoundation (Used)
- (void)addUsedGlobal:(llvm::GlobalValue *)gv;
- (void)addCompilerUsedGlobal:(llvm::GlobalValue *)gv;
- (void)emitLLVMUsed;
- (void)emitUsedName:(llvm::StringRef)name list:(std::vector<llvm::WeakVH> &)list;
@end

@interface __RispLLVMFoundation () {
    llvm::LLVMContext *_context;
    llvm::Module *_theModule;
    llvm::DataLayout *_dataLayout;
    
    __RispLLVMTargetCodeGenInfo *_targetCodeGenInfo;
    
    std::map <std::string, llvm::Value *>_nameValues;
    llvm::IRBuilder<> *_builder;
    ExecutionEngine *_executeEngine;
    
    __RispLLVMObjcType *_objcType;
    
    llvm::SmallPtrSet<llvm::GlobalValue*, 10> WeakRefReferences;
    llvm::StringMap<Constant *>NSConstantStringMap;
    
    llvm::StringMap<llvm::GlobalVariable *>Constant1ByteStringMap;
    
    llvm::DenseMap<RispLLVM::Selector, llvm::GlobalVariable*> SelectorReferences;
    llvm::DenseMap<RispLLVM::IdentifierInfo*, llvm::GlobalVariable*> ClassReferences;
    llvm::DenseMap<RispLLVM::IdentifierInfo*, llvm::GlobalVariable*> SuperClassReferences;
    llvm::DenseMap<RispLLVM::IdentifierInfo*, llvm::GlobalVariable*> MetaClassReferences;
    llvm::DenseMap<RispLLVM::Selector, llvm::GlobalVariable*> MethodVarNames;
    
    llvm::StructType * _NSConstantStringClassTy;
    llvm::Value *_CFConstantStringClassReference;
    
    const LangAS::Map *_addrSpaceMap;

    std::vector<llvm::WeakVH> LLVMUsed;
    std::vector<llvm::WeakVH> LLVMCompilerUsed;
    
    BOOL _ObjCABI;
    
}
- (llvm::Module *)module;
- (llvm::IRBuilder<> *)builder;
- (llvm::StringMap<Constant *>)stringMap;
- (llvm::StructType *)NSConstantStringClassTy;

- (llvm::CallingConv::ID)runtimeCC;
@end

@implementation __RispLLVMFoundation
- (llvm::Module *)module {
    return _theModule;
}

- (IRBuilder<> *)builder {
    return _builder;
}

- (llvm::LLVMContext *)llvmContext {
    return _context;
}

- (StringMap<llvm::Constant *>)stringMap {
    return NSConstantStringMap;
}

- (llvm::StructType *)NSConstantStringClassTy {
    if (!_NSConstantStringClassTy) {
        llvm::Type *fieldTypes[4];
        fieldTypes[0] = llvm::PointerType::getUnqual([_objcType intType]);
        fieldTypes[1] = llvm::IntegerType::getInt32Ty(*_context);
        fieldTypes[2] = [_objcType selectorType];
        fieldTypes[3] = [_objcType longType];
        _NSConstantStringClassTy = llvm::StructType::create(*_context, fieldTypes, "struct.NSConstantString");
    }
    return _NSConstantStringClassTy;
}

- (llvm::CallingConv::ID)runtimeCC {
    return [_targetCodeGenInfo runtimeCC];
}

- (llvm::Value *)CFConstantStringClassReference {
    if (!_CFConstantStringClassReference) {
        llvm::Type *ty = [_objcType intType];
        ty = llvm::ArrayType::get(ty, 0);
        llvm::Constant *gv = [self getOrCreateLLVMGlobal:"__CFConstantStringClassReference" type:llvm::PointerType::getUnqual(ty) unnamedAddress:YES];
        llvm::Constant *zero = llvm::Constant::getNullValue([_objcType intType]);
        llvm::Constant *zeros[] = { zero, zero };
        _CFConstantStringClassReference = llvm::ConstantExpr::getGetElementPtr(gv, zeros);
    }
    return _CFConstantStringClassReference;
}

- (id)init {
    if (self = [super init]) {
        _context = &getGlobalContext();
        _ObjCABI = 2;
        _theModule = new Module("top", *(_context));
        _builder = new IRBuilder<>(*_context);
        _dataLayout = new llvm::DataLayout([self module]);
        _objcType = [__RispLLVMObjcType helper];
        _targetCodeGenInfo = [[__RispLLVMTargetCodeGenInfo alloc] init];
    }
    return self;
}

- (llvm::GlobalValue *)globalValue:(StringRef)name {
    return (*[self module]).getNamedValue(name);
}

- (unsigned)targetAddressSpace:(unsigned)AS {
    if (AS < LangAS::Offset || AS >= LangAS::Offset + LangAS::Count)
        return AS;
    else
        return (*_addrSpaceMap)[AS - LangAS::Offset];
}

- (unsigned)globalVarAddressSpace:(unsigned)addressSpace {
    return [self targetAddressSpace:addressSpace];
}

- (llvm::Constant *)getOrCreateLLVMGlobal:(StringRef)name type:(llvm::PointerType *)ty unnamedAddress:(BOOL)unnamedAddress {
    llvm::GlobalValue *entry = [self globalValue:name];
    if (entry) {
        if (unnamedAddress) {
            entry->setUnnamedAddr(true);
        }
        if (entry->getType() == ty) {
            return entry;
        }
        
        if (entry->getType()->getAddressSpace() != ty->getAddressSpace()) {
            return llvm::ConstantExpr::getAddrSpaceCast(entry, ty);
        }
        return llvm::ConstantExpr::getBitCast(entry, ty);
    }
    unsigned addrSpace = [self globalVarAddressSpace:ty->getAddressSpace()];
    llvm::GlobalVariable *gv = new llvm::GlobalVariable(*[self module], ty->getElementType(), false, llvm::GlobalValue::ExternalLinkage, 0, name, 0, llvm::GlobalVariable::NotThreadLocal, addrSpace);
    if (addrSpace != ty->getAddressSpace()) {
        return llvm::ConstantExpr::getAddrSpaceCast(gv, ty);
    }
    return gv;
}

- (llvm::Constant*)getOrCreateLLVMFunction:(StringRef)mangledName type:(llvm::Type *)ty forVTable:(BOOL)forVTable dontDefer:(BOOL)dontDefer attribute:(llvm::AttributeSet)extraAttrs {
    // Lookup the entry, lazily creating it if necessary.
    llvm::GlobalValue *entry = [self globalValue:mangledName];
    if (entry) {
        if (WeakRefReferences.erase(entry)) {
//            const FunctionDecl *FD = cast_or_null<FunctionDecl>(D);
//            if (FD && !FD->hasAttr<WeakAttr>())
//                Entry->setLinkage(llvm::Function::ExternalLinkage);
        }
        
        if (entry->getType()->getElementType() == ty)
            return entry;
        
        // Make sure the result is of the correct type.
        return llvm::ConstantExpr::getBitCast(entry, ty->getPointerTo());
    }
    
    // This function doesn't have a complete type (for example, the return
    // type is an incomplete struct). Use a fake type instead, and make
    // sure not to try to set attributes.
    bool isIncompleteFunction = false;
    
    llvm::FunctionType *FTy;
    if (llvm::isa<llvm::FunctionType>(ty)) {
        FTy = llvm::cast<llvm::FunctionType>(ty);
    } else {
        FTy = llvm::FunctionType::get([_objcType voidType], false);
        isIncompleteFunction = true;
    }
    
    llvm::Function *function = llvm::Function::Create(FTy, llvm::Function::ExternalLinkage, mangledName, [self module]);
    assert(function->getName() == mangledName && "name was uniqued!");
//    if (D)
//        SetFunctionAttributes(GD, F, IsIncompleteFunction);
    if (extraAttrs.hasAttributes(llvm::AttributeSet::FunctionIndex)) {
        llvm::AttrBuilder builder(extraAttrs, llvm::AttributeSet::FunctionIndex);
        function->addAttributes(llvm::AttributeSet::FunctionIndex,
                                llvm::AttributeSet::get(*_context,
                                                        llvm::AttributeSet::FunctionIndex,
                                                        builder));
    }
    
    //    if (!DontDefer) {
    //        // All MSVC dtors other than the base dtor are linkonce_odr and delegate to
    //        // each other bottoming out with the base dtor.  Therefore we emit non-base
    //        // dtors on usage, even if there is no dtor definition in the TU.
    //        if (D && isa<CXXDestructorDecl>(D) &&
    //            getCXXABI().useThunkForDtorVariant(cast<CXXDestructorDecl>(D),
    //                                               GD.getDtorType()))
    //            addDeferredDeclToEmit(F, GD);
    //
    //        // This is the first use or definition of a mangled name.  If there is a
    //        // deferred decl with this name, remember that we need to emit it at the end
    //        // of the file.
    //        llvm::StringMap<GlobalDecl>::iterator DDI = DeferredDecls.find(MangledName);
    //        if (DDI != DeferredDecls.end()) {
    //            // Move the potentially referenced deferred decl to the
    //            // DeferredDeclsToEmit list, and remove it from DeferredDecls (since we
    //            // don't need it anymore).
    //            addDeferredDeclToEmit(F, DDI->second);
    //            DeferredDecls.erase(DDI);
    //
    //            // Otherwise, if this is a sized deallocation function, emit a weak
    //            // definition
    //            // for it at the end of the translation unit.
    //        } else if (D && cast<FunctionDecl>(D)
    //                   ->getCorrespondingUnsizedGlobalDeallocationFunction()) {
    //            addDeferredDeclToEmit(F, GD);
    //
    //            // Otherwise, there are cases we have to worry about where we're
    //            // using a declaration for which we must emit a definition but where
    //            // we might not find a top-level definition:
    //            //   - member functions defined inline in their classes
    //            //   - friend functions defined inline in some class
    //            //   - special member functions with implicit definitions
    //            // If we ever change our AST traversal to walk into class methods,
    //            // this will be unnecessary.
    //            //
    //            // We also don't emit a definition for a function if it's going to be an
    //            // entry
    //            // in a vtable, unless it's already marked as used.
    //        } else if (getLangOpts().CPlusPlus && D) {
    //            // Look for a declaration that's lexically in a record.
    //            const FunctionDecl *FD = cast<FunctionDecl>(D);
    //            FD = FD->getMostRecentDecl();
    //            do {
    //                if (isa<CXXRecordDecl>(FD->getLexicalDeclContext())) {
    //                    if (FD->isImplicit() && !ForVTable) {
    //                        assert(FD->isUsed() &&
    //                               "Sema didn't mark implicit function as used!");
    //                        addDeferredDeclToEmit(F, GD.getWithDecl(FD));
    //                        break;
    //                    } else if (FD->doesThisDeclarationHaveABody()) {
    //                        addDeferredDeclToEmit(F, GD.getWithDecl(FD));
    //                        break;
    //                    }
    //                }
    //                FD = FD->getPreviousDecl();
    //            } while (FD);
    //        }
    //    }
    
//    getTargetCodeGenInfo().emitTargetMD(D, F, *this);
    
    // Make sure the result is of the requested type.
    if (!isIncompleteFunction) {
        assert(function->getType()->getElementType() == ty);
        return function;
    }
    
    llvm::Type *pty = llvm::PointerType::getUnqual(ty);
    llvm::Constant *c = llvm::ConstantExpr::getBitCast(function, pty);
    llvm::GlobalValue* gv = llvm::cast<llvm::GlobalValue>(c);
    gv->setLinkage(llvm::Function::ExternalWeakLinkage);
    WeakRefReferences.insert(gv);
    return c;
}

- (llvm::Constant *)createRuntimeFunciton:(llvm::FunctionType *)functionTy name:(StringRef)name extraAttributes:(llvm::AttributeSet)extraAttrs {
    llvm::Constant *c = [self getOrCreateLLVMFunction:name type:functionTy forVTable:false dontDefer:false attribute:extraAttrs];
    if (llvm::Function *f = dyn_cast<llvm::Function>(c)) {
        if (f->empty()) {
            f->setCallingConv([self runtimeCC]);
        }
    }
    return c;
}

+ (void)load {
    LLVMInitializeNativeTarget();
    __RispLLVMFoundation *llvm = [[__RispLLVMFoundation alloc] init];
    
    LLVMContext &context = getGlobalContext();
    llvm->_executeEngine = ExecutionEngine::create([llvm module]);
    
    FunctionType *mainFuncType = FunctionType::get([llvm intType], NO);
    Function *mainFunc = Function::Create(mainFuncType, llvm::GlobalValue::PrivateLinkage, "main", [llvm module]);
        
    BasicBlock* label_entry = BasicBlock::Create([llvm module]->getContext(), "entry", mainFunc, 0);
    [llvm builder]->SetInsertPoint(label_entry);
    std::vector<Type *>logArgs;
    logArgs.push_back([llvm idType]);
    FunctionType *logType = FunctionType::get([llvm builder]->getVoidTy(), logArgs, YES);
    Constant *nslog = [llvm module]->getOrInsertFunction("NSLog", logType);
    if (nslog) {
        NSLog(@"have nslog");
        
        if (1) {
            // create NSNumber
            [llvm emitClassNamed:@"NSNumber" isWeak:NO];
            [llvm emitSelector:RispLLVM::Selector(@selector(numberWithFloat:)) isValue:NO];
            [llvm emitSelector:RispLLVM::Selector(@selector(description)) isValue:NO];
        }
        
        llvm::Constant *objcstr = [llvm emitObjCStringLiteral:@"test code-gen for constant string"];
        [llvm builder]->CreateCall(nslog, llvm::ConstantExpr::getBitCast(objcstr, [llvm idType]));
        
        
    }
    //    [llvm builder]->CreateCall(fib, ConstantInt::get([llvm intType], 20));
    //    [llvm builder]->CreateRet(stringAlloc);
    [llvm builder]->CreateRet(ConstantInt::get([llvm intType], 0));

//        ReturnInst::Create([llvm module]->getContext())
    
//    llvm::Constant *Zero = llvm::Constant::getNullValue([llvm intType]);
//    llvm::Constant *Zeros[] = { Zero, Zero };
//    llvm::Value *V;
//    std::string typeInfoName = "__CFConstantStringClassReference";
//    llvm::Type *Ty = llvm::ArrayType::get([llvm intType], 0);
//    llvm::Constant *gv = [llvm getOrCreateLLVMGlobal:typeInfoName type:llvm::PointerType::getUnqual(Ty) unnamedAddress:true];
//    V = llvm::ConstantExpr::getGetElementPtr(gv, Zeros);
    
//    new llvm::GlobalVariable(*[llvm module], llvm::PointerType::getUnqual([llvm intType]), true, llvm::GlobalVariable::ExternalLinkage, nullptr, typeInfoName);
//    GetOrCreateLLVMGlobal(Name, llvm::PointerType::getUnqual(Ty), 0,
//                          true);
//    llvm->_executeEngine->runJITOnFunction(mainFunc);
    
    // code gen for fib 20
    
    // (defn fib [x] (if (< x 2) 1 (+ (fib (dec x)) (fib (- x 2)))))

//    SmallVector<Type *, 1>fibArgs;
//    fibArgs.push_back([llvm intType]);
//    FunctionType *fibType = FunctionType::get([llvm builder]->getInt32Ty(), makeArrayRef(fibArgs), false);
//    Function *fib = Function::Create(fibType, Function::ExternalLinkage, "fib", [llvm module]);
//    int Idx = 0;
//    for (Function::arg_iterator AI = fib->arg_begin(); Idx != fibArgs.size();
//         ++AI, ++Idx) {
//        AI->setName("x");
//        // Add arguments to variable symbol table.
//    }
//
//    BasicBlock *fibEntry = BasicBlock::Create(context, "entry-point", fib);
//    [llvm builder]->SetInsertPoint(fibEntry);
//    
//    // code gen for if
//    Value *condV = [llvm builder]->CreateICmpSLT(&fib->getArgumentList().front(), ConstantInt::get([llvm intType], 2));
//    BasicBlock *thenBlock = BasicBlock::Create(context, "then-entry", fib);
//    BasicBlock *elseBlock = BasicBlock::Create(context, "else-entry", fib);
////    BasicBlock *mergeBlock = BasicBlock::Create(context, "merge-entry", fib);
//    [llvm builder]->CreateCondBr(condV, thenBlock, elseBlock);
//    [llvm builder]->SetInsertPoint(thenBlock);
//    [llvm builder]->CreateRet(ConstantInt::get([llvm intType], 1));
////    [llvm builder]->CreateBr(mergeBlock);
//    
//    [llvm builder]->SetInsertPoint(elseBlock);
//    [llvm builder]->CreateRet([llvm builder]->CreateAdd(([llvm builder]->CreateCall(fib, ([llvm builder]->CreateSub(&fib->getArgumentList().front(), ConstantInt::get([llvm intType], 1))))),
//                                                        ([llvm builder]->CreateCall(fib, ([llvm builder]->CreateSub(&fib->getArgumentList().front(), ConstantInt::get([llvm intType], 2)))))));
//    std::vector<Type *> putsArgs;
//    putsArgs.push_back([llvm builder]->getInt8Ty()->getPointerTo());
//    ArrayRef<Type *> argsRef(putsArgs);
//    FunctionType *putsType = FunctionType::get([llvm builder]->getInt32Ty(), argsRef, false);
//    Constant *putsFunc = [llvm module]->getOrInsertFunction("puts", putsType);
//    [llvm builder]->CreateCall(putsFunc, helloWorld);
//    Value *stringAlloc = [llvm msgSendToTarget:[NSString class] selector:@selector(alloc) arguments:nil];
//    
//    stringAlloc = [llvm msgSend:stringAlloc selector:@selector(initWithUTF8String:) arguments:std::vector<Value *>{helloWorld}];
//    stringAlloc = [llvm msgSend:stringAlloc selector:NSSelectorFromString(@"autorelease") arguments:std::vector<Value *>{}];
    
//    Constant *hello = Constant
//    Constant *cs = llvm::ConstantStruct::get([llvm NSConstantStringClassTy],
//                                             makeArrayRef(std::vector<Constant *> {ConstantInt::get([llvm int64Type], APInt(sizeof(int64_t) * CHAR_BIT, 123)), ConstantInt::get([llvm intType], APInt(sizeof(int) * CHAR_BIT, 3)), helloWorld}));
    
    FunctionPassManager *fpm = new FunctionPassManager([llvm module]);;
    fpm->add(new DataLayoutPass(*llvm->_executeEngine->getDataLayout()));
    fpm->add(createPromoteMemoryToRegisterPass());
    fpm->add(createInstructionCombiningPass());
    fpm->add(createReassociatePass());
    fpm->add(createGVNPass());
    fpm->add(createCFGSimplificationPass());
    
//    fpm->run(*fib);
    fpm->run(*mainFunc);
    
//    [llvm emitLLVMUsed];
    [llvm module]->dump();
    void* ptr = llvm->_executeEngine->getPointerToFunction(mainFunc);
    int (*mainptr)(void) = (int (*)(void))ptr;
//    int n = 20;
    printf("main() -> %d", mainptr());
    
    llvm = nil;
    
    exit(0);
    return;
}

//+ (void)_optimizeFunction:(Function *)f
//{
//    static FunctionPassManager *fpm;
//    if(!fpm)
//    {
//        fpm = new FunctionPassManager(ArrayMapProxyLLVMModule);
//        
//        fpm->add(new DataLayoutPass(*ArrayMapProxyLLVMEngine->getDataLayout()));
//        fpm->add(createPromoteMemoryToRegisterPass());
//        fpm->add(createInstructionCombiningPass());
//        fpm->add(createReassociatePass());
//        fpm->add(createGVNPass());
//        fpm->add(createCFGSimplificationPass());
//    }
//    fpm->run(*f);
//}

- (void)dealloc {
    [self emitLLVMUsed];
    if (_builder) {
        delete _builder;
        _builder = nil;
    }
    
    if (_theModule) {
        delete _theModule;
        _theModule = nil;
    }
}
@end

@implementation __RispLLVMFoundation (CPP)

@end

@interface RispNumberExpression (CodeGen)
- (llvm::Value *)codegen;
@end

@implementation RispNumberExpression (CodeGen)
- (llvm::Value *)codegen {
//    NSDecimalNumber *dn = [self value];
//    llvm::Type *type = (llvm::Type *)([__RispLLVMFoundation llvmTypeFromObjectiveCType:[dn objCType]]);
    return llvm::ConstantFP::get(llvm::getGlobalContext(), llvm::APFloat([[self value] floatValue]));
}
@end

@implementation __RispLLVMFoundation (TypeHelper)
- (llvm::IntegerType *)intType {
    return [_objcType intType];
}

- (llvm::IntegerType *)charType {
    return [_objcType charType];
}

- (llvm::PointerType *)intptrType {
    return [_objcType intptrType];
}

- (llvm::IntegerType *)int64Type {
    return [_objcType int64Type];
}

- (llvm::IntegerType *)longType {
    return [_objcType longType];
}

- (llvm::PointerType *)idType {
    return [_objcType idType];
}

- (llvm::PointerType *)selectorType {
    return [_objcType selectorType];
}

- (llvm::Type *)voidType {
    return [_objcType voidType];
}

- (llvm::Type *)llvmTypeFromObjectiveCType:(const char *)type {
    return [_objcType llvmTypeFromObjectiveCType:type];
}
@end

@implementation __RispLLVMFoundation (Value)
- (Value *)valueForPointer:(void *)ptr builder:(IRBuilder<> &)builder type:(Type *)type name:(const char *)name {
    Value *intv = ConstantInt::get([_objcType int64Type], (int64_t)ptr, 0);
    return builder.CreateIntToPtr(intv, type, name);
}

- (Value *)valueForSelector:(SEL)aSEL builder:(IRBuilder<> &)builder {
    return [self valueForPointer:aSEL builder:builder type:[_objcType selectorType] name:sel_getName(aSEL)];
}

- (Value *)valueForClass:(Class)aClass builder:(IRBuilder<> &)builder {
    return [self valueForPointer:(__bridge void *)aClass builder:builder type:[_objcType idType] name:class_getName(aClass)];
}
@end


@implementation __RispLLVMFoundation (Function)

- (llvm::Function *)msgSend {
    static Function *f;
    if(!f)
    {
        SmallVector<Type *, 16> vec;
        vec.append(1, [_objcType idType]);
        vec.append(1, [_objcType selectorType]);
        ArrayRef<Type *> msgSendArgTypes = makeArrayRef(vec);
        FunctionType *msgSendType = FunctionType::get([_objcType idType], msgSendArgTypes, true);
        f = Function::Create(msgSendType,
                             Function::ExternalLinkage,
                             "objc_msgSend",
                             _theModule);
    }
    return f;
}

@end

@implementation __RispLLVMFoundation (Call)
- (llvm::Value *)msgSendToTarget:(id)target selector:(SEL)cmd arguments:(NSArray *)arguments {
    if (!target) {
        return nil;
    }
    __block std::vector<Value *> args;
    [arguments enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
        args.push_back((Value *)[obj pointerValue]);
    }];
    return [self _msgSendToTarget:target selector:cmd arguments:args];
}

- (llvm::Value *)_msgSendToTarget:(id)target selector:(SEL)cmd arguments:(std::vector<Value *>)arguments {
    return [self msgSend:[self valueForPointer:(__bridge void *)target builder:*_builder type:[_objcType idType] name:"self"] selector:cmd arguments:arguments];
}

- (llvm::Value *)msgSend:(Value *)target selector:(SEL)cmd arguments:(std::vector<Value *>)arguments {
    Function *f = [self msgSend];
    Function::arg_iterator args = f->arg_begin();
    Value *selfarg = args++;
    selfarg->setName("self");
    Value *_cmdarg = args++;
    _cmdarg->setName("_cmd");
    std::vector<Value *>callArgs;
    callArgs.push_back(target);
    callArgs.push_back([self valueForSelector:cmd builder:*_builder]);
    for (std::vector<Value *>::iterator it = arguments.begin(); it != arguments.end(); it++) {
        callArgs.push_back(*it);
    }
    return _builder->CreateCall(f, makeArrayRef(callArgs), "msgSend");
}

@end

@implementation __RispLLVMFoundation (Literal)

- (llvm::GlobalValue *)globalValue:(llvm::StringRef)name {
    return [self module]->getNamedValue(name);
}

- (llvm::GlobalVariable *)generateStringLiteral:(StringRef)string isConstant:(BOOL)constant globalName:(const char *)globalName alignment:(unsigned)alignment {
    llvm::Constant *c = llvm::ConstantDataArray::getString(*[self llvmContext], string, NO);
    unsigned addrSpace = 0;
    llvm::GlobalVariable *gv = new llvm::GlobalVariable(*[self module], c->getType(), constant, llvm::GlobalVariable::PrivateLinkage, c, globalName, 0, llvm::GlobalVariable::NotThreadLocal, addrSpace);
    gv->setAlignment(alignment);
    gv->setUnnamedAddr(true);
    return gv;
}

- (llvm::Constant *)getAddrOfConstantString:(StringRef)str globalName:(const char *)globalName alignment:(unsigned)alignment {
    if (!globalName) globalName = ".str";
    if (alignment == 0)
        alignment = 1;
    llvm::StringMapEntry<llvm::GlobalVariable *>&entry = Constant1ByteStringMap.GetOrCreateValue(str);
    
    llvm::GlobalVariable * gv = entry.getValue();
    if (gv) {
        if (alignment > gv->getAlignment()) {
            gv->setAlignment(alignment);
        }
        return gv;
    }
    gv = [self generateStringLiteral:str isConstant:YES globalName:globalName alignment:alignment];
    return gv;
}

- (Constant *)emitConstantCStringLiteral:(const std::string &)string globalName:(const char *)globalName alignment:(unsigned)alignment {
    StringRef  strWithNull(string.c_str(), string.size() + 1);
    return [self getAddrOfConstantString:strWithNull globalName:globalName alignment:alignment];
}

- (StringMapEntry<Constant *> &)constantStringEntry:(StringMap<Constant *>&)map literal:(const std::string *)literal length:(size_t &)stringLength {
    StringRef string = StringRef(*literal);
    stringLength = string.size();
    return map.GetOrCreateValue(string);
}

- (Constant *)emitObjCStringLiteral:(NSString *)string {
    size_t length = 0;
    BOOL isUTF16 = NO;
    std::string str = std::string([string UTF8String]);
    StringMapEntry<Constant *> &entry = [self constantStringEntry:NSConstantStringMap literal:&str length:length];
    if (llvm::Constant *c = entry.getValue()) {
        return c;
    }
    llvm::Type *ty = [_objcType intType];
    llvm::Constant *zero = llvm::Constant::getNullValue([_objcType intType]);
    llvm::Constant *zeros[] = { zero, zero };
    
    llvm::StructType *sty = cast<llvm::StructType>([self NSConstantStringClassTy]);
    llvm::Constant *fields[4];
    fields[0] = cast<llvm::ConstantExpr>([self CFConstantStringClassReference]);
    fields[1] = isUTF16 ? llvm::ConstantInt::get(ty, 0x07D0) : llvm::ConstantInt::get(ty, 0x07C8);
    llvm::Constant *c = 0;
    
    if (isUTF16) {
        ArrayRef<uint16_t> arr = llvm::makeArrayRef<uint16_t>(reinterpret_cast<uint16_t *>(const_cast<char *>(entry.getKey().data())), entry.getKey().size() / 2);
        c = llvm::ConstantDataArray::get(*_context, arr);
    } else {
        c = llvm::ConstantDataArray::getString(*_context, entry.getKey());
    }
    
    llvm::GlobalVariable *gv = new llvm::GlobalVariable(*[self module], c->getType(), true, llvm::GlobalValue::PrivateLinkage, c, ".str");
    gv->setUnnamedAddr(true);
    if (isUTF16) {
        gv->setAlignment(2);
        gv->setSection("__TEXT,__ustring");
    } else {
        gv->setAlignment(1);
        gv->setSection("__TEXT,__cstring,cstring_literals");
    }
    fields[2] = llvm::ConstantExpr::getGetElementPtr(gv, zeros);
    if (isUTF16) {
        fields[2] = llvm::ConstantExpr::getBitCast(fields[2], [_objcType int8PtrType]);
    }
    ty = [_objcType longType];
    fields[3] = llvm::ConstantInt::get(ty, length);
    c = llvm::ConstantStruct::get(sty, fields);
    gv = new llvm::GlobalVariable(*[self module], c->getType(), true, llvm::GlobalVariable::PrivateLinkage, c, "_unamed_cfstring_");
    gv->setSection("__DATA,__cfstring");
    entry.setValue(gv);
    return gv;
}
@end

@implementation __RispLLVMFoundation (Selector)

- (llvm::GlobalVariable *)createMetadataVar:(Twine)name init:(llvm::Constant *)init section:(const char *)section alignment:(unsigned)align addToUse:(BOOL)addToUsed {
    llvm::Type *ty = init->getType();
    llvm::GlobalVariable *gv = new llvm::GlobalVariable(*[self module], ty, false, llvm::GlobalValue::PrivateLinkage, init, name);
//    assertPrivateName(GV);
    if (section)
        gv->setSection(section);
    if (align)
        gv->setAlignment(align);
    if (addToUsed)
        [self addCompilerUsedGlobal:gv];
    return gv;
}

- (llvm::Constant *)methodVarName:(RispLLVM::Selector)selector {
    llvm::GlobalVariable *&entry = MethodVarNames[selector];
    if (!entry) {
        entry = [self createMetadataVar:"\01L_OBJC_METH_VAR_NAME_" init:llvm::ConstantDataArray::getString(*_context, selector.getAsString()) section:((_ObjCABI == 2) ? "__TEXT,__objc_methname,cstring_literals" : "__TEXT,__cstring,cstring_literals") alignment:1 addToUse:YES];
    }
    return [__RispLLVMFoundation constantGEP:*_context constant:entry idx0:0 idx1:0];
}

- (llvm::Value *)emitSelector:(RispLLVM::Selector)selector isValue:(BOOL)lval {
    llvm::GlobalVariable *&entry = SelectorReferences[selector];
    if (!entry) {
        llvm::Constant *casted = llvm::ConstantExpr::getBitCast([self methodVarName:selector],
                                                                [_objcType selectorType]);
        
//        entry = [self createMetadataVar:"\01L_OBJC_SELECTOR_REFERENCES_" init:casted
//                                section:"__OBJC,__message_refs,literal_pointers,no_dead_strip" alignment:4 addToUse:YES];
        entry = new llvm::GlobalVariable(*[self module], [_objcType selectorType], false,
                                         llvm::GlobalValue::PrivateLinkage,
                                         casted, "\01L_OBJC_SELECTOR_REFERENCES_");
        entry->setExternallyInitialized(true);
        entry->setSection("__DATA, __objc_selrefs, literal_pointers, no_dead_strip");
        [self addCompilerUsedGlobal:entry];
    }
    if (lval) {
        return entry;
    }
    llvm::LoadInst *li = [self builder]->CreateLoad(entry);
    li->setMetadata((*[self module]).getMDKindID("invariant.load"),
                    llvm::MDNode::get(*_context, llvm::ArrayRef<llvm::Value *>()));
    return li;
}

@end

@implementation __RispLLVMFoundation (Class)

- (std::string)objcClassSymbolPrefix {
    return "OBJC_CLASS_$_";
}

- (std::string)metaClassSymbolPrefix {
    return "OBJC_METACLASS_$_";
}

- (llvm::GlobalVariable *)classGlobalWithName:(const std::string&)name isWeak:(BOOL)weak {
    llvm::GlobalValue::LinkageTypes L = weak ? llvm::GlobalValue::ExternalWeakLinkage : llvm::GlobalValue::ExternalLinkage;
    llvm::GlobalVariable *gv = [self module]->getGlobalVariable(name);
    if (!gv) {
        gv = new llvm::GlobalVariable(*[self module], [[__RispLLVMObjcType helper] classnfABITy],
                                      false, L, 0, name);
    }
    assert(gv->getLinkage() == L);
    return gv;
}

- (llvm::Value *)emitClassRefFromId:(RispLLVM::IdentifierInfo *)II isWeak:(BOOL)weak {
    llvm::GlobalVariable *&entry = ClassReferences[II];
    if (!entry) {
        std::string className([self objcClassSymbolPrefix] + II->getName().str());
        llvm::GlobalVariable *classGV = [self classGlobalWithName:className isWeak:weak];
        entry = new llvm::GlobalVariable(*[self module], [[__RispLLVMObjcType helper] classnfABIPtrTy],
                                         false, llvm::GlobalValue::PrivateLinkage,
                                         classGV,
                                         "\01L_OBJC_CLASSLIST_REFERENCES_$_");
        entry->setAlignment(_dataLayout->getABITypeAlignment([_objcType classnfABIPtrTy]));
        entry->setSection("__DATA, __objc_classrefs, regular, no_dead_strip");
        [self addCompilerUsedGlobal:entry];
    }
    return [self builder]->CreateLoad(entry);
}

- (llvm::Value *)emitAutoreleasePoolClassRef {
    return [self emitClassNamed:@"NSAutoreleasePool" isWeak:NO];
}

- (llvm::Value *)emitClassNamed:(NSString *)name isWeak:(BOOL)weak {
    RispLLVM::IdentifierInfo II = RispLLVM::IdentifierInfo([name UTF8String]);
    return [self emitClassRefFromId:&II isWeak:weak];
}

- (llvm::Value *)emitSuperClassRef:(RispLLVM::IdentifierInfo *)II isWeak:(BOOL)weak {
    llvm::GlobalVariable *&entry = SuperClassReferences[II];
    if (!entry) {
        std::string className([self objcClassSymbolPrefix] + II->getName().str());
        llvm::GlobalVariable *classGV = [self classGlobalWithName:className isWeak:weak];
        entry = new llvm::GlobalVariable(*[self module], [_objcType classnfABIPtrTy],
                                         false, llvm::GlobalValue::PrivateLinkage,
                                         classGV,
                                         "\01L_OBJC_CLASSLIST_SUP_REFS_$_");
        entry->setAlignment(_dataLayout->getABITypeAlignment([_objcType classnfABIPtrTy]));
        entry->setSection("__DATA, __objc_superrefs, regular, no_dead_strip");
        [self addCompilerUsedGlobal:entry];
    }
    return [self builder]->CreateLoad(entry);
}

- (llvm::Value *)emitMetaClassRef:(RispLLVM::IdentifierInfo *)II isWeak:(BOOL)weak {
    llvm::GlobalVariable *&entry = MetaClassReferences[II];
    if (!entry) {
        std::string metaClassName([self metaClassSymbolPrefix] + II->getName().str());
        llvm::GlobalVariable *metaClassGV = [self classGlobalWithName:metaClassName isWeak:weak];
        entry = new llvm::GlobalVariable(*[self module], [_objcType classnfABIPtrTy],
                                         false, llvm::GlobalValue::PrivateLinkage,
                                         metaClassGV,
                                         "\01L_OBJC_CLASSLIST_SUP_REFS_$_");
        entry->setAlignment(_dataLayout->getABITypeAlignment([_objcType classnfABIPtrTy]));
        entry->setSection("__DATA, __objc_superrefs, regular, no_dead_strip");
        [self addCompilerUsedGlobal:entry];
    }
    return [self builder]->CreateLoad(entry);
}

- (llvm::Value *)classFromIdentifierInfo:(RispLLVM::IdentifierInfo *)II isWeak:(BOOL)weak {
    if (weak) {
        std::string className([self objcClassSymbolPrefix] + II->getName().str());
        llvm::GlobalVariable *classGV = [self classGlobalWithName:className isWeak:true];
        (void)classGV;
        assert(classGV->getLinkage() == llvm::GlobalVariable::ExternalWeakLinkage);
    }
    return [self emitClassRefFromId:II isWeak:weak];
}

- (llvm::Value *)emitClass {
    return nil;
}

@end

@implementation __RispLLVMFoundation (Used)

- (void)addUsedGlobal:(llvm::GlobalValue *)gv {
    assert(!gv->isDeclaration() &&
           "Only globals with definition can force usage.");
    LLVMUsed.push_back(gv);
}

- (void)addCompilerUsedGlobal:(llvm::GlobalValue *)gv {
    assert(!gv->isDeclaration() &&
           "Only globals with definition can force usage.");
    LLVMCompilerUsed.push_back(gv);
}

- (void)emitUsedName:(llvm::StringRef)name list:(std::vector<llvm::WeakVH> &)list {
    if (list.empty()) {
        return;
    }
    llvm::SmallVector<llvm::Constant*, 8> usedArray;
    usedArray.resize((unsigned int)list.size());
    for (unsigned idx = 0, e = (unsigned)list.size(); idx != e; idx++) {
        usedArray[idx] = llvm::ConstantExpr::getBitCast(cast<llvm::Constant>(&*list[idx]), [_objcType int8PtrType]);
    }
    
    if (usedArray.empty()) {
        return;
    }
    
    llvm::ArrayType *aty = llvm::ArrayType::get([_objcType int8PtrType], usedArray.size());
    llvm::GlobalVariable *gv = new llvm::GlobalVariable(*[self module], aty, false, llvm::GlobalValue::AppendingLinkage, llvm::ConstantArray::get(aty, usedArray), name);
    gv->setSection("llvm.metadata");
}

- (void)emitLLVMUsed {
    [self emitUsedName:"llvm.used" list:LLVMUsed];
    [self emitUsedName:"llvm.compiler.used" list:LLVMCompilerUsed];
}

@end

@implementation __RispLLVMFoundation (Helper)

+ (llvm::Constant *)constantGEP:(llvm::LLVMContext &)VMContext constant:(llvm::Constant *)c idx0:(unsigned)idx0 idx1:(unsigned)idx1 {
    llvm::Value *idxs[] = {
        llvm::ConstantInt::get(llvm::Type::getInt32Ty(VMContext), idx0),
        llvm::ConstantInt::get(llvm::Type::getInt32Ty(VMContext), idx1)
    };
    return llvm::ConstantExpr::getGetElementPtr(c, idxs);
}

@end
