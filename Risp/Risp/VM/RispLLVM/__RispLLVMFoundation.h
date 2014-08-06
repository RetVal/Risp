//
//  __RispLLVMFoundation.h
//  Risp
//
//  Created by closure on 6/10/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <objc/runtime.h>
#include "llvm-c/Core.h"

#include "llvm/InitializePasses.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/JIT.h"

#include "llvm/IR/Type.h"
#include "llvm/Pass.h"
#include "llvm/PassManager.h"
#include "llvm/PassRegistry.h"
#include "llvm/InitializePasses.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Support/StringPool.h"
#include <cstdio>
#include <sstream>

#import "__RispLLVMTargetCodeGenInfo.h"

@interface __RispLLVMObjcType : NSObject
@property (nonatomic, assign, readonly, getter=intType) llvm::IntegerType *intTy;
@property (nonatomic, assign, readonly, getter=charType) llvm::IntegerType *charTy;
@property (nonatomic, assign, readonly, getter=intptrType) llvm::PointerType *intptrTy;
@property (nonatomic, assign, readonly, getter=int64Type) llvm::IntegerType *int64Ty;
@property (nonatomic, assign, readonly, getter=longType) llvm::IntegerType *longTy;
@property (nonatomic, assign, readonly, getter=idType) llvm::PointerType *idTy;
@property (nonatomic, assign, readonly, getter=selectorType) llvm::PointerType *selectorTy;
@property (nonatomic, assign, readonly, getter=voidType) llvm::Type *voidTy;
@property (nonatomic, assign, readonly, getter=int8PtrType) llvm::PointerType *int8PtrTy;
@property (nonatomic, assign, readonly, getter=int8PtrPtrType) llvm::PointerType *int8PtrPtrTy;

@property (nonatomic, assign, readonly) llvm::StructType *propertyTy;
@property (nonatomic, assign, readonly) llvm::StructType *propertyListTy;
@property (nonatomic, assign, readonly) llvm::PointerType *propertyListPtrTy;
@property (nonatomic, assign, readonly) llvm::StructType *methodnfABITy;
@property (nonatomic, assign, readonly) llvm::StructType *cacheTy;
@property (nonatomic, assign, readonly) llvm::PointerType *cachePtrTy;

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
@property (nonatomic, assign, readonly) llvm::Type *impnfABITy;;
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

- (llvm::Constant *)messageSendFn;
@end

@interface __RispLLVMFoundation : NSObject

@end
