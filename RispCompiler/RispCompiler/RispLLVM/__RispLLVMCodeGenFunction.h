//
//  __RispLLVMCodeGenFunction.h
//  Risp
//
//  Created by closure on 8/9/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"

@interface __RispLLVMCodeGenFunction : NSObject
//+ (llvm::Constant *)castFunctionType:(llvm::Constant *)function arguments:(llvm::ArrayRef<llvm::Value *>)args selector:(SEL)selector;
+ (llvm::Constant *)castFunctionType:(llvm::Constant *)function arguments:(llvm::ArrayRef<llvm::Value *>)args selector:(SEL)selector instance:(id)ins;
+ (void)setNamesForFunction:(llvm::Function *)function arugmentNames:(llvm::ArrayRef<llvm::StringRef>)argNames;
@end
