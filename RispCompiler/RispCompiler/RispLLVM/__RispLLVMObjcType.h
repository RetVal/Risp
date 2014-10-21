//
//  __RispLLVMObjcType.h
//  RispCompiler
//
//  Created by closure on 8/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Constant.h"

@class __RispLLVMFoundation;

@interface __RispLLVMObjcType : NSObject
@property (nonatomic, assign, readonly, getter=shortType) llvm::IntegerType *shortTy;
@property (nonatomic, assign, readonly, getter=intType) llvm::IntegerType *intTy;
@property (nonatomic, assign, readonly, getter=int32Type) llvm::IntegerType *int32Ty;
@property (nonatomic, assign, readonly, getter=charType) llvm::IntegerType *charTy;
@property (nonatomic, assign, readonly, getter=intptrType) llvm::PointerType *intptrTy;
@property (nonatomic, assign, readonly, getter=int64Type) llvm::IntegerType *int64Ty;
@property (nonatomic, assign, readonly, getter=longType) llvm::IntegerType *longTy;
@property (nonatomic, assign, readonly, getter=idType) llvm::PointerType *idTy;
@property (nonatomic, assign, readonly, getter=selectorType) llvm::PointerType *selectorTy;
@property (nonatomic, assign, readonly, getter=voidType) llvm::Type *voidTy;
@property (nonatomic, assign, readonly, getter=int8PtrType) llvm::PointerType *int8PtrTy;
@property (nonatomic, assign, readonly, getter=doubleType) llvm::Type *doubleTy;
@property (nonatomic, assign, readonly, getter=int8PtrPtrType) llvm::PointerType *int8PtrPtrTy;
@property (nonatomic, assign, readonly, getter=boolType) llvm::Type *boolTy;

@property (nonatomic, assign, readonly) llvm::StructType *superTy;
@property (nonatomic, assign, readonly) llvm::Type *superPtrTy;
@property (nonatomic, assign, readonly) llvm::StructType *propertyTy;
@property (nonatomic, assign, readonly) llvm::StructType *propertyListTy;
@property (nonatomic, assign, readonly) llvm::PointerType *propertyListPtrTy;
@property (nonatomic, assign, readonly) llvm::StructType *methodnfABITy;
@property (nonatomic, assign, readonly) llvm::StructType *cacheTy;
@property (nonatomic, assign, readonly) llvm::PointerType *cachePtrTy;

@property (nonatomic, assign, readonly) llvm::StructType *symtabTy;
/// SymtabPtrTy - LLVM type for struct objc_symtab *.
@property (nonatomic, assign, readonly) llvm::Type *symtabPtrTy;
/// ModuleTy - LLVM type for struct objc_module.
@property (nonatomic, assign, readonly) llvm::StructType *moduleTy;

/// ProtocolTy - LLVM type for struct objc_protocol.
@property (nonatomic, assign, readonly) llvm::StructType *protocolTy;
/// ProtocolPtrTy - LLVM type for struct objc_protocol *.
@property (nonatomic, assign, readonly) llvm::Type *protocolPtrTy;
/// ProtocolExtensionTy - LLVM type for struct
/// objc_protocol_extension.
@property (nonatomic, assign, readonly) llvm::StructType *protocolExtensionTy;
/// ProtocolExtensionTy - LLVM type for struct
/// objc_protocol_extension *.
@property (nonatomic, assign, readonly) llvm::Type *protocolExtensionPtrTy;
/// MethodDescriptionTy - LLVM type for struct
/// objc_method_description.
@property (nonatomic, assign, readonly) llvm::StructType *methodDescriptionTy;
/// MethodDescriptionListTy - LLVM type for struct
/// objc_method_description_list.
@property (nonatomic, assign, readonly) llvm::StructType *methodDescriptionListTy;
/// MethodDescriptionListPtrTy - LLVM type for struct
/// objc_method_description_list *.
@property (nonatomic, assign, readonly) llvm::Type *methodDescriptionListPtrTy;
/// ProtocolListTy - LLVM type for struct objc_property_list.
@property (nonatomic, assign, readonly) llvm::StructType *protocolListTy;
/// ProtocolListPtrTy - LLVM type for struct objc_property_list*.
@property (nonatomic, assign, readonly) llvm::Type *protocolListPtrTy;
/// CategoryTy - LLVM type for struct objc_category.
@property (nonatomic, assign, readonly) llvm::StructType *categoryTy;
/// ClassTy - LLVM type for struct objc_class.
@property (nonatomic, assign, readonly) llvm::StructType *classTy;
/// ClassPtrTy - LLVM type for struct objc_class *.
@property (nonatomic, assign, readonly) llvm::Type *classPtrTy;
/// ClassExtensionTy - LLVM type for struct objc_class_ext.
@property (nonatomic, assign, readonly) llvm::StructType *classExtensionTy;
/// ClassExtensionPtrTy - LLVM type for struct objc_class_ext *.
@property (nonatomic, assign, readonly) llvm::Type *classExtensionPtrTy;
// IvarTy - LLVM type for struct objc_ivar.
@property (nonatomic, assign, readonly) llvm::StructType *ivarTy;
/// IvarListTy - LLVM type for struct objc_ivar_list.
@property (nonatomic, assign, readonly) llvm::Type *ivarListTy;
/// IvarListPtrTy - LLVM type for struct objc_ivar_list *.
@property (nonatomic, assign, readonly) llvm::Type *ivarListPtrTy;
/// MethodListTy - LLVM type for struct objc_method_list.
@property (nonatomic, assign, readonly) llvm::Type *methodListTy;
/// MethodListPtrTy - LLVM type for struct objc_method_list *.
@property (nonatomic, assign, readonly) llvm::Type *methodListPtrTy;

/// ExceptionDataTy - LLVM type for struct _objc_exception_data.
@property (nonatomic, assign, readonly) llvm::Type *exceptionDataTy;




@property (nonatomic, assign, readonly) llvm::StructType *methodListnfABITy;
@property (nonatomic, assign, readonly) llvm::Type *methodListnfABIPtrTy;
@property (nonatomic, assign, readonly) llvm::StructType *protocolnfABITy;
@property (nonatomic, assign, readonly) llvm::Type *protocolnfABIPtrTy;
@property (nonatomic, assign, readonly) llvm::StructType *protocolListnfABITy;
@property (nonatomic, assign, readonly) llvm::Type *protocolListnfABIPtrTy;
@property (nonatomic, assign, readonly) llvm::StructType *classnfABITy;
@property (nonatomic, assign, readonly) llvm::Type *classnfABIPtrTy;
@property (nonatomic, assign, readonly) llvm::StructType *ivarnfABITy;
@property (nonatomic, assign, readonly) llvm::Type *ivarnfABIPtrTy;
@property (nonatomic, assign, readonly) llvm::StructType *ivarListnfABITy;
@property (nonatomic, assign, readonly) llvm::Type *ivarListnfABIPtrTy;
@property (nonatomic, assign, readonly) llvm::StructType *classRonfABITy;
@property (nonatomic, assign, readonly) llvm::Type *impnfABITy;
@property (nonatomic, assign, readonly) llvm::StructType *categorynfABITy;
@property (nonatomic, assign, readonly) llvm::StructType *messageRefTy;
@property (nonatomic, assign, readonly) llvm::Type *messageRefPtrTy;
@property (nonatomic, assign, readonly) llvm::FunctionType *messengerTy;
@property (nonatomic, assign, readonly) llvm::StructType *superMessageRefTy;
@property (nonatomic, assign, readonly) llvm::Type *superMessageRefPtrTy;

@property (nonatomic, assign, readonly) llvm::StructType *ehTypeTy;
@property (nonatomic, assign, readonly) llvm::Type *ehTypePtrTy;

+ (instancetype)helper;
- (llvm::Type *)llvmTypeFromObjectiveCType:(const char *)type;

- (llvm::Constant *)messageSendFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)messageSendStretFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)messageSendFpretFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)messageSendFp2retFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)messageSendSuperFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)messageSendSuperFn2:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)messageSendSuperStretFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)messageSendSuperStretFn2:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)messageSendSuperFpretFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)messageSendSuperFpretFn2:(__RispLLVMFoundation *)cgm;

- (llvm::Constant *)propertyFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)setPropertyFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)optimizedSetPropertyFn:(__RispLLVMFoundation *)cgm isAtomic:(BOOL)atomic isCopy:(BOOL)copy;
- (llvm::Constant *)copyStructFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)cppAtomicObjectFunction:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)enumerationMutationFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)gcReadWeakFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)gcAssignWeakFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)gcAssignGlobalFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)gcAssignThreadLocalFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)gcAssignIvarFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)gcMemmoveCollectableFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)gcAssignStrongCastFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)exceptionThrowFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)exceptionRethrowFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)syncEnterFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)syncExitFn:(__RispLLVMFoundation *)cgm;

- (llvm::Constant *)sendFn:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)sendFn2:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)sendStretFn:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)sendStretFn2:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)sendFpretFn:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)sendFpretFn2:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)sendFp2retFn:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)sendFp2RetFn2:(BOOL)isSuper cgm:(__RispLLVMFoundation *)cgm;

- (llvm::Constant *)exceptionTryEnterFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)exceptionTryExitFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)exceptionExtractFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)exceptionMatchFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)setJmpFn:(__RispLLVMFoundation *)cgm;

- (llvm::Constant *)messageSendFixupFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)messageSendFpretFixupFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)messageSendStretFixupFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)messageSendSuper2FixupFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)messageSendSuper2StretFixupFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)objCEndCatchFn:(__RispLLVMFoundation *)cgm;
- (llvm::Constant *)objCBeginCatchFn:(__RispLLVMFoundation *)cgm;

@end
