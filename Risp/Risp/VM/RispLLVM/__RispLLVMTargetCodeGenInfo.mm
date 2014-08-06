//
//  __RispLLVMTargetCodeGenInfo.m
//  Risp
//
//  Created by closure on 8/6/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "__RispLLVMTargetCodeGenInfo.h"

@implementation __RispLLVMTargetCodeGenInfo
- (instancetype)init {
    if (self = [super init]) {
        _runtimeCC = llvm::CallingConv::C;
    }
    return self;
}
@end
