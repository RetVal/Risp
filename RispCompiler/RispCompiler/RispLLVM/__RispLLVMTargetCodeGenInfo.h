//
//  __RispLLVMTargetCodeGenInfo.h
//  Risp
//
//  Created by closure on 8/6/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "llvm/IR/Type.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/Support/TargetRegistry.h"

typedef NS_ENUM(NSUInteger, RispLLVMLanguageOptions) {
    RispLLVMLanguageARC = 1
};

@interface __RispLLVMTargetCodeGenInfo : NSObject
@property (nonatomic, assign, readonly) RispLLVMLanguageOptions languageOption;
@property (nonatomic, assign, readonly) llvm::CallingConv::ID runtimeCC;
@property (nonatomic, assign, readonly, getter=pointerDiffType) llvm::Type * pointerDiffTy;
@property (nonatomic, assign, readonly) llvm::Triple *targetTriple;

@property (nonatomic, assign, readonly) unsigned charWidth;

- (instancetype)init;
- (const llvm::fltSemantics *)halfFormat;
- (const llvm::fltSemantics *)floatFormat;
- (const llvm::fltSemantics *)doubleFormat;
- (const llvm::fltSemantics *)longDoubleFormat;

- (unsigned)pointerWidth:(unsigned)width;

@end