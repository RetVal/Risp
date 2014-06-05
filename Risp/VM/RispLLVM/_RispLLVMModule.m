//
//  _RispLLVMModule.m
//  Risp
//
//  Created by closure on 6/1/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "_RispLLVMModule.h"

@implementation _RispLLVMModule
+ (instancetype)module:(LLVMModuleRef)llvmModule {
    return [[_RispLLVMModule alloc] initWithLLVMMoudle:llvmModule];
}

- (instancetype)initWithLLVMMoudle:(LLVMModuleRef)llvmModule {
    if (self = [super init]) {
        _module = llvmModule;
    }
    return self;
}

- (void)dealloc {
    LLVMDisposeModule(_module);
    _module = nil;
}

@end
