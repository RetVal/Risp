//
//  __RispLLVMObjcType.m
//  RispCompiler
//
//  Created by closure on 8/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "__RispLLVMObjcType.h"
#import "__RispLLVMFoundation.h"

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

- (llvm::Type *)llvmTypeFromObjectiveCType:(const char *)type {
    if (type == nil) {
        return nil;
    }
#define IF_ISTYPE(t) if(strcmp(@encode(t), type) == 0)
#define INT_TYPE(t) IF_ISTYPE(t) return llvm::IntegerType::get(*_VMContext, sizeof(t) * CHAR_BIT)
#define PTR_TYPE(t) IF_ISTYPE(t) return llvm::PointerType::getUnqual([self charType])
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
    IF_ISTYPE(float) return llvm::Type::getFloatTy(*_VMContext);
    IF_ISTYPE(double) return llvm::Type::getDoubleTy(*_VMContext);
    IF_ISTYPE(void) return llvm::Type::getVoidTy(*_VMContext);
    PTR_TYPE(char *);
    PTR_TYPE(id);
    PTR_TYPE(SEL);
    PTR_TYPE(Class);
    if(type[0] == '^') return llvm::PointerType::getUnqual([self charType]);
    
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
        _idTy = llvm::PointerType::get(([self charType]), 0);
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

