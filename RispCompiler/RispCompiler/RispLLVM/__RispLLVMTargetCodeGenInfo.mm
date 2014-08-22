//
//  __RispLLVMTargetCodeGenInfo.m
//  Risp
//
//  Created by closure on 8/6/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "__RispLLVMTargetCodeGenInfo.h"
#import "__RispLLVMFoundation.h"
#include "llvm/Support/Host.h"
#import "__RispLLVMObjcType.h"

@implementation __RispLLVMTargetCodeGenInfo
- (instancetype)init {
    if (self = [super init]) {
        _runtimeCC = llvm::CallingConv::C;
        _pointerDiffTy = [[__RispLLVMObjcType helper] longType];
        _targetTriple = new llvm::Triple(llvm::sys::getDefaultTargetTriple());
    }
    return self;
}

- (const llvm::fltSemantics *)halfFormat {
    return &llvm::APFloat::IEEEhalf;
}

- (const llvm::fltSemantics *)floatFormat {
    return &llvm::APFloat::IEEEsingle;
}

- (const llvm::fltSemantics *)doubleFormat {
    return &llvm::APFloat::IEEEdouble;
}

- (const llvm::fltSemantics *)longDoubleFormat {
    return &llvm::APFloat::IEEEdouble;
}

- (void)dealloc {
    delete _targetTriple;
}
@end
