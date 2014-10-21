//
//  __RispLLVMFoundation.h
//  Risp
//
//  Created by closure on 6/10/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef __RISPLLVM_FOUNDATION__
#define __RISPLLVM_FOUNDATION__

#import <Foundation/Foundation.h>
#include <objc/runtime.h>

#include "llvm/InitializePasses.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/LLVMContext.h"

#include "llvm/Support/StringPool.h"

#import "__RispLLVMTargetCodeGenInfo.h"
#import "__RispLLVMTargetMachineCodeGen.h"
#import "__RispLLVMIRCodeGen.h"
#import "__RispLLVMCodeGenFunction.h"
#import "__RispLLVMTypeConverter.h"

#include "RispLLVMSelector.h"
#include "RispLLVMIdentifierInfo.h"
#import "RispASTContextDoneOptions.h"
#include "LanguageOptions.h"

FOUNDATION_EXPORT NSString * __RispLLVMFoundationObjectPathKey;
FOUNDATION_EXPORT NSString * __RispLLVMFoundationAsmPathKey;
FOUNDATION_EXPORT NSString * __RispLLVMFoundationLLVMIRPathKey;


@class __RispLLVMFoundation;

@interface __RispLLVMFoundation : NSObject
@property (nonatomic, strong, readonly) NSString *moduleName;
@property (nonatomic, strong) NSString *outputPath;

- (instancetype)initWithModuleName:(NSString *)name;
- (llvm::Module *)module;
- (llvm::IRBuilder<> *)builder;
- (llvm::StringMap<llvm::Constant *>&)stringMap;
- (llvm::StructType *)NSConstantStringClassTy;

- (__RispLLVMTargetCodeGenInfo *)targetCodeGenInfo;
- (llvm::CallingConv::ID)runtimeCC;
- (llvm::LLVMContext *)llvmContext;
- (RispLLVM::LanguageOptions &)languageOptions;
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
- (llvm::Type *)floatType;
- (llvm::Type *)doubleType;
- (llvm::Type *)ptrDiffType;
- (llvm::Type *)classType;
- (llvm::PointerType *)classPtrTYpe;
- (llvm::Type *)llvmTypeFromObjectiveCType:(const char *)type;
@end

@interface __RispLLVMFoundation (Value)
- (llvm::Value *)valueForPointer:(void *)ptr builder:(llvm::IRBuilder<> &)builder type:(llvm::Type *)type name:(const char *)name;
- (llvm::Value *)valueForSelector:(SEL)aSEL builder:(llvm::IRBuilder<> &)builder;
- (llvm::Value *)valueForClass:(Class)aClass builder:(llvm::IRBuilder<> &)builder;

- (llvm::Constant *)emitNullConstant:(llvm::Type *)t;
@end

@interface __RispLLVMFoundation (Function)
- (llvm::Constant *)createRuntimeFunciton:(llvm::FunctionType *)functionTy name:(llvm::StringRef)name extraAttributes:(llvm::AttributeSet)extraAttrs;
- (llvm::Function *)msgSend;
@end

@interface __RispLLVMFoundation (Memory)
- (llvm::Value *)malloc:(NSUInteger)size;
- (llvm::Value *)malloc:(NSUInteger)size inBlock:(llvm::BasicBlock *)bb;
@end

@interface __RispLLVMFoundation (Call)
- (llvm::Value *)msgSendToTarget:(id)target selector:(SEL)cmd arguments:(NSArray *)arguments;
- (llvm::Value *)msgSend:(llvm::Value *)target selector:(SEL)cmd arguments:(std::vector<llvm::Value *>)arguments;
- (llvm::Value *)emitMessageCall:(llvm::Value *)target selector:(SEL)selector arguments:(llvm::ArrayRef<llvm::Value *>)arguments instance:(id)ins;
@end

@interface __RispLLVMFoundation (Literal)
- (llvm::GlobalValue *)globalValue:(llvm::StringRef)name;
- (llvm::Value *)emitNSDecimalNumberLiteral:(double)value;
- (llvm::Value *)emitNSNull;
- (llvm::Constant *)getAddrOfConstantString:(llvm::StringRef)str globalName:(const char *)globalName alignment:(unsigned)alignment;
- (llvm::Constant *)emitObjCStringLiteral:(NSString *)string;
- (llvm::Constant *)emitConstantCStringLiteral:(const std::string &)string globalName:(const char *)globalName alignment:(unsigned)alignment;
- (llvm::Constant *)getOrCreateLLVMGlobal:(llvm::StringRef)name type:(llvm::PointerType *)ty unnamedAddress:(BOOL)unnamedAddress;
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
- (void)emitImageInfo;
- (void)emitVersionIdentMetadata;
- (void)emitLazySymbols;
- (void)emitUsedName:(llvm::StringRef)name list:(std::vector<llvm::WeakVH> &)list;
- (NSDictionary *)doneWithOptions:(RispASTContextDoneOptions)options;
@end

#endif
