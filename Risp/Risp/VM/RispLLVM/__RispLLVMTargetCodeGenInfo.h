//
//  __RispLLVMTargetCodeGenInfo.h
//  Risp
//
//  Created by closure on 8/6/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "llvm/IR/CallingConv.h"

@interface __RispLLVMTargetCodeGenInfo : NSObject
@property (nonatomic, assign, readonly) llvm::CallingConv::ID runtimeCC;
- (instancetype)init;
@end