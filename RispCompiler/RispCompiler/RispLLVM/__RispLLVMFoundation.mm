//
//  __RispLLVMFoundation.m
//  Risp
//
//  Created by closure on 6/10/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "__RispLLVMFoundation.h"
#include "RispLLVM.h"
#include "CodenGenModule.h"

namespace RispLLVM {
    class Selector;
    class IdentifierInfo;
}

enum ImageInfoFlags {
    eImageInfo_FixAndContinue      = (1 << 0), // This flag is no longer set by clang.
    eImageInfo_GarbageCollected    = (1 << 1),
    eImageInfo_GCOnly              = (1 << 2),
    eImageInfo_OptimizedByDyld     = (1 << 3), // This flag is set by the dyld shared cache.
    
    // A flag indicating that the module has no instances of a @synthesize of a
    // superclass variable. <rdar://problem/6803242>
    eImageInfo_CorrectedSynthesize = (1 << 4), // This flag is no longer set by clang.
    eImageInfo_ImageIsSimulated    = (1 << 5)
};

@interface __RispLLVMFoundation (Value)
- (llvm::Value *)valueForPointer:(void *)ptr builder:(llvm::IRBuilder<> &)builder type:(llvm::Type *)type name:(const char *)name;
- (llvm::Value *)valueForSelector:(SEL)aSEL builder:(llvm::IRBuilder<> &)builder;
- (llvm::Value *)valueForClass:(Class)aClass builder:(llvm::IRBuilder<> &)builder;

- (llvm::Constant *)emitNullConstant:(llvm::Type *)t;
@end

@interface __RispLLVMFoundation (Function)
- (llvm::Constant *)createRuntimeFunciton:(llvm::FunctionType *)functionTy name:(StringRef)name extraAttributes:(llvm::AttributeSet)extraAttrs;
- (llvm::Function *)msgSend;
@end

@interface __RispLLVMFoundation (Call)
- (llvm::Value *)msgSendToTarget:(id)target selector:(SEL)cmd arguments:(NSArray *)arguments;
- (llvm::Value *)msgSend:(llvm::Value *)target selector:(SEL)cmd arguments:(std::vector<Value *>)arguments;
- (llvm::Value *)emitMessageCall:(llvm::Value *)target selector:(SEL)selector arguments:(llvm::ArrayRef<llvm::Value *>)arguments;
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
- (llvm::Value *)createVariable:(llvm::Type *)type named:(llvm::StringRef)name;
- (llvm::Value *)setValue:(llvm::Value *)value forVariable:(llvm::Value *)variable;
- (llvm::Value *)setValue:(llvm::Value *)value forVariable:(llvm::Value *)variable isVolatile:(BOOL)isVolatile;
- (llvm::Value *)valueForVariable:(llvm::Value *)variable;
@end

@interface __RispLLVMFoundation (Math)
- (llvm::Value *)mul:(llvm::Value *)lhs rhs:(llvm::Value *)rhs;
- (llvm::Value *)mul:(llvm::ArrayRef<llvm::Value *>)values;
@end

@interface __RispLLVMFoundation (Used)
- (void)addUsedGlobal:(llvm::GlobalValue *)gv;
- (void)addCompilerUsedGlobal:(llvm::GlobalValue *)gv;
- (void)emitLLVMUsed;
- (void)emitUsedName:(llvm::StringRef)name list:(std::vector<llvm::WeakVH> &)list;
@end

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
    
    class RValue {
        enum Flavor { Scalar, Complex, Aggregate };
        
        // Stores first value and flavor.
        llvm::PointerIntPair<llvm::Value *, 2, Flavor> V1;
        // Stores second value and volatility.
        llvm::PointerIntPair<llvm::Value *, 1, bool> V2;
        
    public:
        bool isScalar() const { return V1.getInt() == Scalar; }
        bool isComplex() const { return V1.getInt() == Complex; }
        bool isAggregate() const { return V1.getInt() == Aggregate; }
        
        bool isVolatileQualified() const { return V2.getInt(); }
        
        /// getScalarVal() - Return the Value* of this scalar value.
        llvm::Value *getScalarVal() const {
            assert(isScalar() && "Not a scalar!");
            return V1.getPointer();
        }
        
        /// getComplexVal - Return the real/imag components of this complex value.
        ///
        std::pair<llvm::Value *, llvm::Value *> getComplexVal() const {
            return std::make_pair(V1.getPointer(), V2.getPointer());
        }
        
        /// getAggregateAddr() - Return the Value* of the address of the aggregate.
        llvm::Value *getAggregateAddr() const {
            assert(isAggregate() && "Not an aggregate!");
            return V1.getPointer();
        }
        
        static RValue get(llvm::Value *V) {
            RValue ER;
            ER.V1.setPointer(V);
            ER.V1.setInt(Scalar);
            ER.V2.setInt(false);
            return ER;
        }
        static RValue getComplex(llvm::Value *V1, llvm::Value *V2) {
            RValue ER;
            ER.V1.setPointer(V1);
            ER.V2.setPointer(V2);
            ER.V1.setInt(Complex);
            ER.V2.setInt(false);
            return ER;
        }
        static RValue getComplex(const std::pair<llvm::Value *, llvm::Value *> &C) {
            return getComplex(C.first, C.second);
        }
        // FIXME: Aggregate rvalues need to retain information about whether they are
        // volatile or not.  Remove default to find all places that probably get this
        // wrong.
        static RValue getAggregate(llvm::Value *V, bool Volatile = false) {
            RValue ER;
            ER.V1.setPointer(V);
            ER.V1.setInt(Aggregate);
            ER.V2.setInt(Volatile);
            return ER;
        }
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

@interface __RispLLVMFoundation () {
    llvm::LLVMContext *_context;
    llvm::Module *_theModule;
    llvm::DataLayout *_dataLayout;
    
    RispLLVM::CodeGenFunction *_CGF;
    
    __RispLLVMTargetCodeGenInfo *_targetCodeGenInfo;
    
    std::map <std::string, llvm::Value *>_nameValues;
    llvm::IRBuilder<> *_builder;
    llvm::ExecutionEngine *_executeEngine;
    
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
@end

@interface __RispLLVMObjcType () {
@private
    llvm::LLVMContext *_VMContext;
//    llvm::IntegerType *_intTy;
//    llvm::IntegerType *_charTy;
//    llvm::IntegerType *_int64Ty;
//    llvm::IntegerType *_longTy;
    llvm::IntegerType *_unsignedIntTy;
//    llvm::PointerType *_intptrTy;
//    llvm::PointerType *_int8PtrTy;
//    llvm::PointerType *_int8PtrPtrTy;
//    
//    llvm::PointerType *_idTy;
//    llvm::PointerType *_selectorTy;
//    llvm::Type *_voidTy;
    llvm::Type *_voidPtrTy;
    llvm::Type *_doubleTy;
    
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
#define INT_TYPE(t) IF_ISTYPE(t) return IntegerType::get(*_VMContext, sizeof(t) * CHAR_BIT)
#define PTR_TYPE(t) IF_ISTYPE(t) return PointerType::getUnqual([self charType])
    INT_TYPE(bool);
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
    IF_ISTYPE(float) return Type::getFloatTy(*_VMContext);
    IF_ISTYPE(double) return Type::getDoubleTy(*_VMContext);
    IF_ISTYPE(void) return Type::getVoidTy(*_VMContext);
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
        _VMContext = &llvm::getGlobalContext();
        _boolTy = llvm::IntegerType::get(*_VMContext, sizeof(bool) * CHAR_BIT);
        _intTy = llvm::IntegerType::get(*_VMContext, sizeof(int) * CHAR_BIT);
        _charTy = llvm::IntegerType::get(*_VMContext, CHAR_BIT);
        _intptrTy = llvm::IntegerType::getInt32PtrTy(*_VMContext);
        _idTy = llvm::PointerType::getUnqual([self charType]);;
        _selectorTy = llvm::PointerType::getUnqual([self charType]);
        _int64Ty = llvm::IntegerType::get(*_VMContext, sizeof(int64_t) * CHAR_BIT);
        _int32Ty = llvm::IntegerType::get(*_VMContext, sizeof(int32_t) * CHAR_BIT);
        _longTy = llvm::IntegerType::get(*_VMContext, sizeof(long) * CHAR_BIT);
        _unsignedIntTy = llvm::IntegerType::get(*_VMContext, sizeof(unsigned int) * CHAR_BIT);
        _int8PtrTy = llvm::PointerType::getUnqual(llvm::IntegerType::get(*_VMContext, sizeof(int8_t) * CHAR_BIT));
        _int8PtrPtrTy = llvm::PointerType::getUnqual([self int8PtrType]);
        _shortTy = llvm::IntegerType::get(*_VMContext, sizeof(short) * CHAR_BIT);
        _voidTy = llvm::PointerType::getVoidTy(*_VMContext);
        
        _voidPtrTy = _int8PtrTy;
        
        _doubleTy = llvm::Type::getDoubleTy(*_VMContext);
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
        
        _cacheTy = llvm::StructType::create(*_VMContext, "struct._objc_cache");
        _cachePtrTy = llvm::PointerType::getUnqual(_cacheTy);
        
        // struct _objc_method_description {
        //   SEL name;
        //   char *types;
        // }
        _methodDescriptionTy = llvm::StructType::create("struct._objc_method_description",
                                 _selectorTy, _int8PtrTy, NULL);
        
        // struct _objc_method_description_list {
        //   int count;
        //   struct _objc_method_description[1];
        // }
        _methodDescriptionListTy =
        llvm::StructType::create("struct._objc_method_description_list",
                                 _intTy,
                                 llvm::ArrayType::get(_methodDescriptionTy, 0),NULL);
        
        // struct _objc_method_description_list *
        _methodDescriptionListPtrTy =
        llvm::PointerType::getUnqual(_methodDescriptionListTy);
        
        // Protocol description structures
        
        // struct _objc_protocol_extension {
        //   uint32_t size;  // sizeof(struct _objc_protocol_extension)
        //   struct _objc_method_description_list *optional_instance_methods;
        //   struct _objc_method_description_list *optional_class_methods;
        //   struct _objc_property_list *instance_properties;
        //   const char ** extendedMethodTypes;
        // }
        _protocolExtensionTy =
        llvm::StructType::create("struct._objc_protocol_extension",
                                 _intTy, _methodDescriptionListPtrTy,
                                 _methodDescriptionListPtrTy, _propertyListPtrTy,
                                 _int8PtrPtrTy, NULL);
        
        // struct _objc_protocol_extension *
        _protocolExtensionPtrTy = llvm::PointerType::getUnqual(_protocolExtensionTy);
        
        // Handle recursive construction of Protocol and ProtocolList types
        
        _protocolTy =
        llvm::StructType::create(*_VMContext, "struct._objc_protocol");
        
        _protocolListTy =
        llvm::StructType::create(*_VMContext, "struct._objc_protocol_list");
        _protocolListTy->setBody(llvm::PointerType::getUnqual(_protocolListTy),
                                _longTy,
                                llvm::ArrayType::get(_protocolTy, 0),
                                NULL);
        
        // struct _objc_protocol {
        //   struct _objc_protocol_extension *isa;
        //   char *protocol_name;
        //   struct _objc_protocol **_objc_protocol_list;
        //   struct _objc_method_description_list *instance_methods;
        //   struct _objc_method_description_list *class_methods;
        // }
        _protocolTy->setBody(_protocolExtensionPtrTy, _int8PtrTy,
                            llvm::PointerType::getUnqual(_protocolListTy),
                            _methodDescriptionListPtrTy,
                            _methodDescriptionListPtrTy,
                            NULL);
        
        // struct _objc_protocol_list *
        _protocolListPtrTy = llvm::PointerType::getUnqual(_protocolListTy);
        
        _protocolPtrTy = llvm::PointerType::getUnqual(_protocolTy);
        
        // Class description structures
        
        // struct _objc_ivar {
        //   char *ivar_name;
        //   char *ivar_type;
        //   int  ivar_offset;
        // }
        _ivarTy = llvm::StructType::create("struct._objc_ivar",
                                          _int8PtrTy, _int8PtrTy, _intTy, NULL);
        
        // struct _objc_ivar_list *
        _ivarListTy =
        llvm::StructType::create(*_VMContext, "struct._objc_ivar_list");
        _ivarListPtrTy = llvm::PointerType::getUnqual(_ivarListTy);
        
        // struct _objc_method_list *
        _methodListTy =
        llvm::StructType::create(*_VMContext, "struct._objc_method_list");
        _methodListPtrTy = llvm::PointerType::getUnqual(_methodListTy);
        
        // struct _objc_class_extension *
        _classExtensionTy =
        llvm::StructType::create("struct._objc_class_extension",
                                 _intTy, _int8PtrTy, _propertyListPtrTy, NULL);
        _classExtensionPtrTy = llvm::PointerType::getUnqual(_classExtensionTy);
        
        _classTy = llvm::StructType::create(*_VMContext, "struct._objc_class");
        
        // struct _objc_class {
        //   Class isa;
        //   Class super_class;
        //   char *name;
        //   long version;
        //   long info;
        //   long instance_size;
        //   struct _objc_ivar_list *ivars;
        //   struct _objc_method_list *methods;
        //   struct _objc_cache *cache;
        //   struct _objc_protocol_list *protocols;
        //   char *ivar_layout;
        //   struct _objc_class_ext *ext;
        // };
        _classTy->setBody(llvm::PointerType::getUnqual(_classTy),
                         llvm::PointerType::getUnqual(_classTy),
                         _int8PtrTy,
                         _longTy,
                         _longTy,
                         _longTy,
                         _ivarListPtrTy,
                         _methodListPtrTy,
                         _cachePtrTy,
                         _protocolListPtrTy,
                         _int8PtrTy,
                         _classExtensionPtrTy,
                         NULL);
        
        _classPtrTy = llvm::PointerType::getUnqual(_classTy);
        
        // struct _objc_category {
        //   char *category_name;
        //   char *class_name;
        //   struct _objc_method_list *instance_method;
        //   struct _objc_method_list *class_method;
        //   uint32_t size;  // sizeof(struct _objc_category)
        //   struct _objc_property_list *instance_properties;// category's @property
        // }
        _categoryTy =
        llvm::StructType::create("struct._objc_category",
                                 _int8PtrTy, _int8PtrTy, _methodListPtrTy,
                                 _methodListPtrTy, _protocolListPtrTy,
                                 _intTy, _propertyListPtrTy, NULL);
        
        // Global metadata structures
        
        // struct _objc_symtab {
        //   long sel_ref_cnt;
        //   SEL *refs;
        //   short cls_def_cnt;
        //   short cat_def_cnt;
        //   char *defs[cls_def_cnt + cat_def_cnt];
        // }
        _symtabTy =
        llvm::StructType::create("struct._objc_symtab",
                                 _longTy, _selectorTy, _shortTy, _shortTy,
                                 llvm::ArrayType::get(_int8PtrTy, 0), NULL);
        _symtabPtrTy = llvm::PointerType::getUnqual(_symtabTy);
        
        // struct _objc_module {
        //   long version;
        //   long size;   // sizeof(struct _objc_module)
        //   char *name;
        //   struct _objc_symtab* symtab;
        //  }
        _moduleTy =
        llvm::StructType::create("struct._objc_module",
                                 _longTy, _longTy, _int8PtrTy, _symtabPtrTy, NULL);
        
        
        // FIXME: This is the size of the setjmp buffer and should be target
        // specific. 18 is what's used on 32-bit X86.
        uint64_t SetJmpBufferSize = 18;
        
        // Exceptions
        llvm::Type *StackPtrTy = llvm::ArrayType::get(_int8PtrTy, 4);
        
        _exceptionDataTy =
        llvm::StructType::create("struct._objc_exception_data",
                                 llvm::ArrayType::get(_int32Ty, SetJmpBufferSize),
                                 StackPtrTy, NULL);
        
        
        // struct _method_list_t {
        //   uint32_t entsize;  // sizeof(struct _objc_method)
        //   uint32_t method_count;
        //   struct _objc_method method_list[method_count];
        // }
        _methodListnfABITy = llvm::StructType::create("struct.__method_list_t", _intTy, _intTy, llvm::ArrayType::get(_methodnfABITy, 0), nil);
        _methodListnfABIPtrTy = llvm::PointerType::getUnqual(_methodListnfABITy);
        
        _protocolListnfABITy = llvm::StructType::create(*_VMContext, "struct._objc_protocol_list");
        
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
        _classnfABITy = llvm::StructType::create(*_VMContext, "struct._class_t");
        _classnfABITy->setBody(llvm::PointerType::getUnqual(_classnfABITy),
                              llvm::PointerType::getUnqual(_classnfABITy),
                              _cachePtrTy,
                              llvm::PointerType::getUnqual(_impnfABITy),
                              llvm::PointerType::getUnqual(_classRonfABITy),
                              nil);
        // LLVM for struct _class_t *
        _classnfABIPtrTy = llvm::PointerType::getUnqual(_classnfABITy);
        
        // struct _objc_super {
        //   id self;
        //   Class cls;
        // }
        _superTy = llvm::StructType::create("struct._objc_super", _idTy, _classnfABITy, nil);
        _superPtrTy = llvm::PointerType::getUnqual(_superTy);
        
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
        // _messageRefPtrTy - LLVM for struct _message_ref_t*
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

- (llvm::Constant *)messageSendFn:(__RispLLVMFoundation *)cgm {
    // The types of these functions don't really matter because we
    // should always bitcast before calling them.
    
    /// id objc_msgSend (id, SEL, ...)
    ///
    /// The default messenger, used for sends whose ABI is unchanged from
    /// the all-integer/pointer case.
    
    llvm::Type *params[] = {_idTy, _selectorTy};
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_idTy, params, true)
                                 name:"objc_msgSend"
                      extraAttributes:llvm::AttributeSet::get(*[cgm llvmContext],
                                                              llvm::AttributeSet::FunctionIndex,
                                                              llvm::Attribute::NonLazyBind)];
}

- (llvm::Constant *)messageSendStretFn:(__RispLLVMFoundation *)cgm {
    /// void objc_msgSend_stret (id, SEL, ...)
    ///
    /// The messenger used when the return value is an aggregate returned
    /// by indirect reference in the first argument, and therefore the
    /// self and selector parameters are shifted over by one.
    
    llvm::Type *params[] = {_idTy, _selectorTy};
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_voidTy, params, true)
                                 name:"objc_msgSend_stret"
                      extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)messageSendFpretFn:(__RispLLVMFoundation *)cgm {
    /// [double | long double] objc_msgSend_fpret(id self, SEL op, ...)
    ///
    /// The messenger used when the return value is returned on the x87
    /// floating-point stack; without a special entrypoint, the nil case
    /// would be unbalanced.
    
    llvm::Type *params[] = {_idTy, _selectorTy};
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_doubleTy, params, true)
                                 name:"objc_msgSend_fpret"
                      extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)messageSendFp2retFn:(__RispLLVMFoundation *)cgm {
    /// _Complex long double objc_msgSend_fp2ret(id self, SEL op, ...)
    ///
    /// The messenger used when the return value is returned in two values on the
    /// x87 floating point stack; without a special entrypoint, the nil case
    /// would be unbalanced. Only used on 64-bit X86.
    
    llvm::Type *params[] = {_idTy, _selectorTy};
    llvm::Type *longDoubleType = llvm::Type::getX86_FP80Ty(*_VMContext);
    llvm::Type *resultType = llvm::StructType::get(longDoubleType, longDoubleType, nil);
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(resultType, params, true)
                                 name:"objc_msgSend_fp2ret"
                      extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)messageSendSuperFn:(__RispLLVMFoundation *)cgm {
    /// id objc_msgSendSuper(struct objc_super *super, SEL op, ...)
    ///
    /// The messenger used for super calls, which have different dispatch
    /// semantics.  The class passed is the superclass of the current
    /// class.
    
    llvm::Type *params[] = {_superPtrTy, _selectorTy};
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_idTy, params, true)
                                 name:"objc_msgSendSuper"
                      extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)messageSendSuperFn2:(__RispLLVMFoundation *)cgm {
    /// id objc_msgSendSuper2(struct objc_super *super, SEL op, ...)
    ///
    /// A slightly different messenger used for super calls.  The class
    /// passed is the current class.
    
    llvm::Type *params[] = {_superPtrTy, _selectorTy};
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_idTy, params, true)
                                 name:"objc_msgSendSuper2"
                      extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)messageSendSuperStretFn:(__RispLLVMFoundation *)cgm {
    /// void objc_msgSendSuper_stret(void *stretAddr, struct objc_super *super,
    ///                              SEL op, ...)
    ///
    /// The messenger used for super calls which return an aggregate indirectly.
    
    llvm::Type *params[] = {_int8PtrTy, _superPtrTy, _selectorTy};
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_voidTy, params, true)
                                 name:"objc_msgSendSuper_stret"
                      extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)messageSendSuperStretFn2:(__RispLLVMFoundation *)cgm {
    /// void objc_msgSendSuper2_stret(void * stretAddr, struct objc_super *super,
    ///                               SEL op, ...)
    ///
    /// objc_msgSendSuper_stret with the super2 semantics.
    
    llvm::Type *params[] = {_int8PtrTy, _superPtrTy, _selectorTy};
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_voidTy, params, true)
                                 name:"objc_msgSendSuper2_stret"
                      extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)messageSendSuperFpretFn:(__RispLLVMFoundation *)cgm {
    return [self messageSendSuperFn:cgm];
}

- (llvm::Constant *)messageSendSuperFpretFn2:(__RispLLVMFoundation *)cgm {
    return [self messageSendSuperFn2:cgm];
}

- (llvm::Constant *)propertyFn:(__RispLLVMFoundation *)cgm {
    llvm::SmallVector<llvm::Type *, 4>params;
    params.push_back(_idTy);
    params.push_back(_selectorTy);
    params.push_back([[cgm targetCodeGenInfo] pointerDiffType]); // ptrdiff_t
    params.push_back(_boolTy);
    llvm::FunctionType *functionTy = llvm::FunctionType::get(_idTy, params, false);
    // id objc_getProperty (id, SEL, ptrdiff_t, bool)
    return [cgm createRuntimeFunciton:functionTy name:"objc_getProperty" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)setPropertyFn:(__RispLLVMFoundation *)cgm {
    llvm::SmallVector<llvm::Type *, 6> params;
    params.push_back(_idTy);
    params.push_back(_selectorTy);
    params.push_back([[cgm targetCodeGenInfo] pointerDiffType]);
    params.push_back(_idTy);
    params.push_back(_boolTy);
    params.push_back(_boolTy);
    llvm::FunctionType *functionTy = llvm::FunctionType::get(_voidTy, params, false);
    // void objc_setProperty (id, SEL, ptrdiff_t, id, bool, bool)
    return [cgm createRuntimeFunciton:functionTy name:"objc_setProperty" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)optimizedSetPropertyFn:(__RispLLVMFoundation *)cgm isAtomic:(BOOL)atomic isCopy:(BOOL)copy {
    // void objc_setProperty_atomic(id self, SEL _cmd,
    //                              id newValue, ptrdiff_t offset);
    // void objc_setProperty_nonatomic(id self, SEL _cmd,
    //                                 id newValue, ptrdiff_t offset);
    // void objc_setProperty_atomic_copy(id self, SEL _cmd,
    //                                   id newValue, ptrdiff_t offset);
    // void objc_setProperty_nonatomic_copy(id self, SEL _cmd,
    //                                      id newValue, ptrdiff_t offset);

    llvm::SmallVector<llvm::Type *, 4> params;
    params.push_back(_idTy);
    params.push_back(_selectorTy);
    params.push_back(_idTy);
    params.push_back([[cgm targetCodeGenInfo] pointerDiffType]);
    llvm::FunctionType *functionType = llvm::FunctionType::get(_voidTy, params, false);
    const char *name;
    if (atomic && copy) {
        name = "objc_setProperty_atomic_copy";
    } else if (atomic && !copy) {
        name = "objc_setProperty_atomic";
    } else if (!atomic && copy) {
        name = "objc_setProperty_nonatomic_copy";
    } else {
        name = "objc_setProperty_nonatomic";
    }
    return [cgm createRuntimeFunciton:functionType name:name extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)copyStructFn:(__RispLLVMFoundation *)cgm {
    // void objc_copyStruct (void *, const void *, size_t, bool, bool)
    
    llvm::SmallVector<llvm::Type *, 5> params;
    params.push_back(_voidPtrTy);
    params.push_back(_voidPtrTy);
    params.push_back(_longTy);
    params.push_back(_boolTy);
    params.push_back(_boolTy);
    llvm::FunctionType *functionType = llvm::FunctionType::get(_voidTy, params, false);
    return [cgm createRuntimeFunciton:functionType name:"objc_copyStruct" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)cppAtomicObjectFunction:(__RispLLVMFoundation *)cgm {
    /// This routine declares and returns address of:
    /// void objc_copyCppObjectAtomic(
    ///         void *dest, const void *src,
    ///         void (*copyHelper) (void *dest, const void *source));
    
    llvm::SmallVector<llvm::Type *, 3> params;
    params.push_back(_voidPtrTy);
    params.push_back(_voidPtrTy);
    params.push_back(_voidPtrTy);
    llvm::FunctionType *functionType = llvm::FunctionType::get(_voidTy, params, false);
    return [cgm createRuntimeFunciton:functionType name:"objc_copyCppObjectAtomic" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)enumerationMutationFn:(__RispLLVMFoundation *)cgm {
    // void objc_enumerationMutation (id)
    
    llvm::SmallVector<llvm::Type *, 1> params;
    params.push_back(_idTy);
    llvm::FunctionType *functionType = llvm::FunctionType::get(_voidTy, params, false);
    return [cgm createRuntimeFunciton:functionType name:"objc_enumerationMutation" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)gcReadWeakFn:(__RispLLVMFoundation *)cgm {
    // id objc_read_weak (id *)
    
    llvm::SmallVector<llvm::Type *, 1> params;
    params.push_back(_idTy->getPointerTo());
    llvm::FunctionType *functionType = llvm::FunctionType::get(_voidTy, params, false);
    return [cgm createRuntimeFunciton:functionType name:"objc_read_weak" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)gcAssignWeakFn:(__RispLLVMFoundation *)cgm {
    // id objc_assign_weak (id, id *)
    
    llvm::SmallVector<llvm::Type *, 1> params;
    params.push_back(_idTy);
    params.push_back(_idTy->getPointerTo());
    llvm::FunctionType *functionType = llvm::FunctionType::get(_idTy, params, false);
    return [cgm createRuntimeFunciton:functionType name:"objc_assign_weak" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)gcAssignGlobalFn:(__RispLLVMFoundation *)cgm {
    // id objc_assign_global(id, id *)
    
    llvm::SmallVector<llvm::Type *, 1> params;
    params.push_back(_idTy);
    params.push_back(_idTy->getPointerTo());
    llvm::FunctionType *functionType = llvm::FunctionType::get(_idTy, params, false);
    return [cgm createRuntimeFunciton:functionType name:"objc_assign_global" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)gcAssignThreadLocalFn:(__RispLLVMFoundation *)cgm {
    // id objc_assign_threadlocal(id src, id * dest)
    
    llvm::SmallVector<llvm::Type *, 1> params;
    params.push_back(_idTy);
    params.push_back(_idTy->getPointerTo());
    llvm::FunctionType *functionType = llvm::FunctionType::get(_idTy, params, false);
    return [cgm createRuntimeFunciton:functionType name:"objc_assign_threadlocal" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)gcAssignIvarFn:(__RispLLVMFoundation *)cgm {
    // id objc_assign_ivar(id, id *, ptrdiff_t)
    
    llvm::SmallVector<llvm::Type *, 3> params;
    params.push_back(_idTy);
    params.push_back(_idTy->getPointerTo());
    params.push_back([[cgm targetCodeGenInfo] pointerDiffType]);
    llvm::FunctionType *functionType = llvm::FunctionType::get(_idTy, params, false);
    return [cgm createRuntimeFunciton:functionType name:"objc_assign_ivar" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)gcMemmoveCollectableFn:(__RispLLVMFoundation *)cgm {
    // void *objc_memmove_collectable(void *dst, const void *src, size_t size)
    
    llvm::Type *args[] = {_int8PtrTy, _int8PtrTy, _longTy};
    llvm::FunctionType *functionType = llvm::FunctionType::get(_int8PtrTy, args, false);
    return [cgm createRuntimeFunciton:functionType name:"objc_memmove_collectable" extraAttributes:llvm::AttributeSet()];
}

/// GcAssignStrongCastFn -- LLVM objc_assign_strongCast function.
- (llvm::Constant *)gcAssignStrongCastFn:(__RispLLVMFoundation *)cgm {
    // id objc_assign_strongCast(id, id *)
    llvm::Type *args[] = { _idTy, _idTy->getPointerTo()};
    llvm::FunctionType *functionType = llvm::FunctionType::get(_idTy, args, false);
    return [cgm createRuntimeFunciton:functionType name:"objc_assign_strongCast" extraAttributes:llvm::AttributeSet()];
}

/// ExceptionThrowFn - LLVM objc_exception_throw function.
- (llvm::Constant *)exceptionThrowFn:(__RispLLVMFoundation *)cgm {
    // void objc_exception_throw(id)
    llvm::Type *args[] = { _idTy };
    llvm::FunctionType *functionType = llvm::FunctionType::get(_voidTy, args, false);
    return [cgm createRuntimeFunciton:functionType name:"objc_exception_throw" extraAttributes:llvm::AttributeSet()];
}

/// ExceptionRethrowFn - LLVM objc_exception_rethrow function.
- (llvm::Constant *)exceptionRethrowFn:(__RispLLVMFoundation *)cgm {
    // void objc_exception_rethrow(void)
    llvm::FunctionType *functionType = llvm::FunctionType::get(_voidTy, false);
    return [cgm createRuntimeFunciton:functionType name:"objc_exception_rethrow" extraAttributes:llvm::AttributeSet()];
}

/// SyncEnterFn - LLVM object_sync_enter function.
- (llvm::Constant *)syncEnterFn:(__RispLLVMFoundation *)cgm {
    // int objc_sync_enter (id)
    llvm::Type *args[] = { _idTy };
    llvm::FunctionType *functionType = llvm::FunctionType::get(_intTy, args, false);
    return [cgm createRuntimeFunciton:functionType name:"objc_sync_enter" extraAttributes:llvm::AttributeSet()];
}

/// SyncExitFn - LLVM object_sync_exit function.
- (llvm::Constant *)syncExitFn:(__RispLLVMFoundation *)cgm {
    // int objc_sync_exit (id)
    llvm::Type *args[] = { _idTy };
    llvm::FunctionType *functionType = llvm::FunctionType::get(_intTy, args, false);
    return [cgm createRuntimeFunciton:functionType name:"objc_sync_exit" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)sendFn:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm {
    return isSuper ? [self messageSendSuperFn:cgm] : [self messageSendFn:cgm];
}

- (llvm::Constant *)sendFn2:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm {
    return isSuper ? [self messageSendSuperFn2:cgm] : [self messageSendFn:cgm];
}

- (llvm::Constant *)sendStretFn:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm {
    return isSuper ? [self messageSendSuperStretFn:cgm] : [self messageSendStretFn:cgm];
}

- (llvm::Constant *)sendStretFn2:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm {
    return isSuper ? [self messageSendSuperStretFn2:cgm] : [self messageSendStretFn:cgm];
}

- (llvm::Constant *)sendFpretFn:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm {
    return isSuper ? [self messageSendSuperFpretFn:cgm] : [self messageSendFpretFn:cgm];
}

- (llvm::Constant *)sendFpretFn2:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm {
    return isSuper ? [self messageSendSuperFpretFn2:cgm] : [self messageSendFpretFn:cgm];
}

- (llvm::Constant *)sendFp2retFn:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm {
    return isSuper ? [self messageSendSuperFn:cgm] : [self messageSendFp2retFn:cgm];
}

- (llvm::Constant *)sendFp2RetFn2:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm {
    return isSuper ? [self messageSendSuperFn2:cgm] : [self messageSendFp2retFn:cgm];
}

- (llvm::Constant *)exceptionTryEnterFn:(__RispLLVMFoundation *)cgm {
    llvm::Type *params[] = { _exceptionDataTy->getPointerTo() };
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_voidTy, params, false) name:"objc_exception_try_enter" extraAttributes:llvm::AttributeSet()];
}

/// ExceptionTryExitFn - LLVM objc_exception_try_exit function.
- (llvm::Constant *)exceptionTryExitFn:(__RispLLVMFoundation *)cgm {
    llvm::Type *params[] = { _exceptionDataTy->getPointerTo() };
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_voidTy, params, false) name:"objc_exception_try_exit" extraAttributes:llvm::AttributeSet()];
}

/// ExceptionExtractFn - LLVM objc_exception_extract function.
- (llvm::Constant *)exceptionExtractFn:(__RispLLVMFoundation *)cgm {
    llvm::Type *params[] = { _exceptionDataTy->getPointerTo() };
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_idTy, params, false) name:"objc_exception_extract" extraAttributes:llvm::AttributeSet()];
}

/// ExceptionMatchFn - LLVM objc_exception_match function.
- (llvm::Constant *)exceptionMatchFn:(__RispLLVMFoundation *)cgm {
    llvm::Type *params[] = { _classPtrTy, _idTy };
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_int32Ty, params, false) name:"objc_exception_match" extraAttributes:llvm::AttributeSet()];
}

/// SetJmpFn - LLVM _setjmp function.
- (llvm::Constant *)setJmpFn:(__RispLLVMFoundation *)cgm {
    // This is specifically the prototype for x86.
    llvm::Type *params[] = { _int32Ty->getPointerTo() };
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_int32Ty, params, false) name:"_setjmp" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)messageSendFixupFn:(__RispLLVMFoundation *)cgm {
    // id objc_msgSend_fixup(id, struct message_ref_t*, ...)
    llvm::Type *params[] = { _idTy, _messageRefPtrTy };
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_idTy, params, true) name:"objc_msgSend_fixup" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)messageSendFpretFixupFn:(__RispLLVMFoundation *)cgm {
    // id objc_msgSend_fpret_fixup(id, struct message_ref_t*, ...)
    llvm::Type *params[] = { _idTy, _messageRefPtrTy };
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_idTy, params, true) name:"objc_msgSend_fpret_fixup" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)messageSendStretFixupFn:(__RispLLVMFoundation *)cgm {
    // id objc_msgSend_stret_fixup(id, struct message_ref_t*, ...)
    llvm::Type *params[] = { _idTy, _messageRefPtrTy };
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_idTy, params, true) name:"objc_msgSend_stret_fixup" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)messageSendSuper2FixupFn:(__RispLLVMFoundation *)cgm {
    // id objc_msgSendSuper2_fixup (struct objc_super *,
    //                              struct _super_message_ref_t*, ...)
    llvm::Type *params[] = { _superPtrTy, _superMessageRefPtrTy };
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_idTy, params, true) name:"objc_msgSendSuper2_fixup" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)messageSendSuper2StretFixupFn:(__RispLLVMFoundation *)cgm {
    // id objc_msgSendSuper2_stret_fixup(struct objc_super *,
    //                                   struct _super_message_ref_t*, ...)
    llvm::Type *params[] = { _superPtrTy, _superMessageRefPtrTy };
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_idTy, params, true) name:"objc_msgSendSuper2_stret_fixup" extraAttributes:llvm::AttributeSet()];
}

- (llvm::Constant *)objCEndCatchFn:(__RispLLVMFoundation *)cgm {
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_voidTy, false) name:"objc_end_catch" extraAttributes:llvm::AttributeSet()];
    
}

- (llvm::Constant *)objCBeginCatchFn:(__RispLLVMFoundation *)cgm {
    llvm::Type *params[] = { _int8PtrTy };
    return [cgm createRuntimeFunciton:llvm::FunctionType::get(_int8PtrTy, params, false) name:"objc_begin_catch" extraAttributes:llvm::AttributeSet()];
}

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

- (RispLLVM::CodeGenFunction &)CGF {
    return *_CGF;
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

- (__RispLLVMTargetCodeGenInfo *)targetCodeGenInfo {
    return _targetCodeGenInfo;
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
        _CGF = new RispLLVM::CodeGenFunction(self);
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
    
    llvm::FunctionType *functionType;
    if (llvm::isa<llvm::FunctionType>(ty)) {
        functionType = llvm::cast<llvm::FunctionType>(ty);
    } else {
        functionType = llvm::FunctionType::get([_objcType voidType], false);
        isIncompleteFunction = true;
    }
    
    llvm::Function *function = llvm::Function::Create(functionType, llvm::Function::ExternalLinkage, mangledName, [self module]);
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
    
    if (_CGF) {
        delete [] _CGF;
    }
}
@end

@implementation __RispLLVMFoundation (CPP)

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

- (llvm::Type *)floatType {
    return [_objcType llvmTypeFromObjectiveCType:@encode(float)];
}

- (llvm::Type *)doubleType {
    return [_objcType llvmTypeFromObjectiveCType:@encode(double)];
}

- (llvm::Type *)ptrDiffType {
    return [_targetCodeGenInfo pointerDiffType];
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

- (llvm::Constant *)emitNullConstant:(llvm::Type *)t {
    if (t->isArrayTy()) {
        llvm::ArrayType *arrayType = cast<llvm::ArrayType>(t);
        llvm::Type *elementType = arrayType->getElementType();
        llvm::Constant *element = [self emitNullConstant:elementType];
        if (element->isNullValue()) {
            return llvm::ConstantAggregateZero::get(arrayType);
        }
        unsigned numberElements = (unsigned)arrayType->getNumElements();
        llvm::SmallVector<llvm::Constant *, 8> array(numberElements, element);
        return llvm::ConstantArray::get(arrayType, array);
    }
    return llvm::Constant::getNullValue(t);
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

- (llvm::Constant *)createRuntimeFunciton:(llvm::FunctionType *)functionTy name:(StringRef)name extraAttributes:(llvm::AttributeSet)extraAttrs {
    llvm::Constant *c = [self getOrCreateLLVMFunction:name type:functionTy forVTable:false dontDefer:false attribute:extraAttrs];
    if (llvm::Function *f = dyn_cast<llvm::Function>(c)) {
        if (f->empty()) {
            f->setCallingConv([self runtimeCC]);
        }
    }
    return c;
}
@end

@implementation __RispLLVMFoundation (Call)
- (llvm::Value *)msgSendToTarget:(id)target selector:(SEL)cmd arguments:(NSArray *)arguments {
    if (!target) {
        return nil;
    }
    __block std::vector<llvm::Value *> args;
    [arguments enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
        args.push_back((llvm::Value *)[obj pointerValue]);
    }];
    return [self _msgSendToTarget:target selector:cmd arguments:args];
}

- (llvm::Value *)_msgSendToTarget:(id)target selector:(SEL)cmd arguments:(std::vector<llvm::Value *>)arguments {
    return [self msgSend:[self valueForPointer:(__bridge void *)target builder:*_builder type:[_objcType idType] name:"self"] selector:cmd arguments:arguments];
}

- (llvm::Value *)msgSend:(llvm::Value *)target selector:(SEL)cmd arguments:(std::vector<llvm::Value *>)arguments {
    llvm::Function *f = [self msgSend];
    llvm::Function::arg_iterator args = f->arg_begin();
    llvm::Value *selfarg = args++;
    selfarg->setName("self");
    llvm::Value *_cmdarg = args++;
    _cmdarg->setName("_cmd");
    std::vector<llvm::Value *>callArgs;
    callArgs.push_back(target);
    callArgs.push_back([self valueForSelector:cmd builder:*_builder]);
    for (std::vector<llvm::Value *>::iterator it = arguments.begin(); it != arguments.end(); it++) {
        callArgs.push_back(*it);
    }
    return _builder->CreateCall(f, makeArrayRef(callArgs), "msgSend");
}

- (llvm::Value *)emitMessageCall:(llvm::Value *)target selector:(SEL)selector arguments:(llvm::ArrayRef<llvm::Value *>)_args {
    llvm::Value *sel = [self emitSelector:RispLLVM::Selector(selector) isValue:NO];
    if (!sel) return nil;
    llvm::Constant *msgSend = [_objcType messageSendFn:self];
    llvm::SmallVector<llvm::Value *, 5> args;
    args.push_back(_builder->CreateBitCast(target, [_objcType idType]));
    args.push_back(sel);
    if (_args.size()) {
        args.append(_args.begin(), _args.end());
        msgSend = [__RispLLVMCodeGenFunction castFunctionType:msgSend arguments:args];
    }
    return _builder->CreateCall(msgSend, args);
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
    gv = new llvm::GlobalVariable(*[self module], c->getType(), true, llvm::GlobalVariable::PrivateLinkage, c, "_unnamed_cfstring_");
    gv->setSection("__DATA,__cfstring");
    entry.setValue(gv);
    return gv;
}
@end

@implementation __RispLLVMFoundation (Selector)

- (llvm::GlobalVariable *)createMetadataVar:(Twine)name init:(llvm::Constant *)init section:(const char *)section alignment:(unsigned)align addToUse:(BOOL)addToUsed {
    llvm::Type *ty = init->getType();
    llvm::GlobalVariable *gv = new llvm::GlobalVariable(*[self module], ty, false, llvm::GlobalValue::InternalLinkage, init, name);
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
                                         llvm::GlobalValue::InternalLinkage,
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
                                         false, llvm::GlobalValue::InternalLinkage,
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

- (void)emitImageInfo {
    unsigned version = 0; // Version is unused?
    const char *Section = (_ObjCABI == 1) ?
    "__OBJC, __image_info,regular" :
    "__DATA, __objc_imageinfo, regular, no_dead_strip";
    
    // Generate module-level named metadata to convey this information to the
    // linker and code-gen.
    llvm::Module &mod = *[self module];
    
    // Add the ObjC ABI version to the module flags.
    mod.addModuleFlag(llvm::Module::Error, "Objective-C Version", _ObjCABI);
    mod.addModuleFlag(llvm::Module::Error, "Objective-C Image Info Version",
                      version);
    mod.addModuleFlag(llvm::Module::Error, "Objective-C Image Info Section",
                      llvm::MDString::get(*_context, Section));
    
    mod.addModuleFlag(llvm::Module::Override,
                      "Objective-C Garbage Collection", (uint32_t)0);
    
    // Indicate whether we're compiling this to run on a simulator.
//    const llvm::Triple &Triple = CGM.getTarget().getTriple();
    const llvm::Triple &triple = *[_targetCodeGenInfo targetTriple];
    if (triple.isiOS() &&
        (triple.getArch() == llvm::Triple::x86 ||
         triple.getArch() == llvm::Triple::x86_64))
        mod.addModuleFlag(llvm::Module::Error, "Objective-C Is Simulated", eImageInfo_ImageIsSimulated);
}

- (void)emitVersionIdentMetadata {
    llvm::NamedMDNode *IdentMetadata = [self module]->getOrInsertNamedMetadata("llvm.ident");
    std::string Version = "RispLLVM Version 0.1";
    llvm::LLVMContext &Ctx = *_context;
    
    llvm::Value *IdentNode[] = {
        llvm::MDString::get(Ctx, Version)
    };
    IdentMetadata->addOperand(llvm::MDNode::get(Ctx, IdentNode));
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

- (llvm::Value *)createVariable:(llvm::Type *)type named:(llvm::StringRef)name {
    llvm::AllocaInst *alloc = _builder->CreateAlloca(type);
    alloc->setName(name);
    alloc->setAlignment(_dataLayout->getABITypeAlignment(type));
    return alloc;
}

- (llvm::Value *)setValue:(llvm::Value *)value forVariable:(llvm::Value *)variable {
    llvm::Type *valueType = value->getType();
    llvm::Type *variableType = variable->getType()->getPointerElementType();
    if (valueType != variableType) {
        value = [__RispLLVMTypeConverter conversionValue:value toType:variableType CGM:self];
    }
    return _builder->CreateStore(value, variable);
}

- (llvm::Value *)setValue:(llvm::Value *)value forVariable:(llvm::Value *)variable isVolatile:(BOOL)isVolatile {
    return _builder->CreateStore(value, variable, isVolatile);
}

- (llvm::Value *)valueForVariable:(llvm::Value *)variable {
    return _builder->CreateLoad(variable);
}

@end

@implementation __RispLLVMFoundation (Math)

- (llvm::Value *)mul:(llvm::Value *)lhs rhs:(llvm::Value *)rhs {
    return _builder->CreateMul(lhs, rhs);
}

- (llvm::Value *)mul:(llvm::ArrayRef<llvm::Value *>)values {
    if (values.size() == 0) return nil;
    else if (values.size() == 1) return values[0];
    llvm::Value *r = _builder->CreateMul(values[0], values[1]);
    for (size_t i = 2; i < values.size(); ++i) {
        llvm::Value *v = values[i];
        r = _builder->CreateMul(r, v);
    }
    return r;
}

@end

@implementation __RispLLVMFoundation (Load)

+ (void)load {
    LLVMInitializeNativeTarget();
    __RispLLVMFoundation *llvm = [[__RispLLVMFoundation alloc] init];
    
    //    LLVMContext &context = getGlobalContext();
    llvm->_executeEngine = ExecutionEngine::create([llvm module]);
    
    FunctionType *mainFuncType = FunctionType::get([llvm intType], {[llvm intType], [llvm charType]->getPointerTo()->getPointerTo()}, NO);
    Function *mainFunc = Function::Create(mainFuncType, llvm::GlobalValue::ExternalLinkage, "main", [llvm module]);
    
    [__RispLLVMCodeGenFunction setNamesForFunction:mainFunc arugmentNames:{"argc", "argv"}];
    
    BasicBlock* label_entry = BasicBlock::Create([llvm module]->getContext(), "entry", mainFunc, 0);
    [llvm builder]->SetInsertPoint(label_entry);
    std::vector<Type *>logArgs;
    logArgs.push_back([llvm idType]);
    FunctionType *logType = FunctionType::get([llvm builder]->getVoidTy(), logArgs, YES);
    Constant *nslog = [llvm module]->getOrInsertFunction("NSLog", logType);
    if (nslog) {
        llvm::Value *NSNumberClass = [llvm emitClassNamed:@"NSNumber" isWeak:NO];
        llvm::Value *nsnumber = [llvm emitMessageCall:NSNumberClass selector:@selector(numberWithInt:) arguments:{llvm::ConstantInt::get([llvm intType], 123)}];
        llvm::Value *desc = [llvm emitMessageCall:nsnumber selector:@selector(description) arguments:{}];
        llvm::Constant *objcstr = [llvm emitObjCStringLiteral:@"%@"];
        [llvm builder]->CreateCall(nslog, {llvm::ConstantExpr::getBitCast(objcstr, [llvm idType]), desc});
    }

    llvm::Value *numberVariable = [llvm createVariable:[llvm floatType] named:"n"];
    llvm::Value *v1 = llvm::ConstantInt::getSigned([llvm intType], 2);
    llvm::Value *v2 = llvm::ConstantInt::getSigned([llvm intType], 3);
    llvm::Value *v3 = llvm::ConstantInt::getSigned([llvm intType], 10);
    [llvm setValue:[llvm mul:{v1, v2, v3}] forVariable:numberVariable];
    
    [llvm builder]->CreateRet(ConstantInt::get([llvm intType], 0));

    [llvm emitLLVMUsed];
    [llvm emitImageInfo];
    [llvm emitVersionIdentMetadata];
    std::string output;
    [__RispLLVMTargetMachineCodeGen compileASMModule:[llvm module] context:*[llvm llvmContext] output:output];
    [__RispLLVMTargetMachineCodeGen compileObjectModule:[llvm module] context:*[llvm llvmContext] outputPath:@"~/Desktop/risp.o"];
    NSLog(@"%@", [__RispLLVMIRCodeGen IRCodeFromModule:[llvm module]]);
    llvm::errs() << "\nRispLLVM 0.1 -> \n" << output;
//    FunctionPassManager *fpm = new FunctionPassManager([llvm module]);;
//    fpm->add(new DataLayoutPass(*llvm->_executeEngine->getDataLayout()));
//    fpm->add(createPromoteMemoryToRegisterPass());
//    fpm->add(createInstructionCombiningPass());
//    fpm->add(createReassociatePass());
//    fpm->add(createGVNPass());
//    fpm->add(createCFGSimplificationPass());
//    
//    //    fpm->run(*fib);
//    fpm->run(*mainFunc);
//    
//    
    
//    void* ptr = llvm->_executeEngine->getPointerToFunction(mainFunc);
//    int (*mainptr)(int argc, char **argv) = (int (*)(int argc, char **argv))ptr;
////    int n = 20;
//    int argc = 1;
//    char *_argv = "test";
//    char **argv = &_argv;
//    printf("main(%d, %p) -> %d", argc, argv, mainptr(argc, argv));
//    
    llvm = nil;
    
    exit(0);
    return;
}

@end