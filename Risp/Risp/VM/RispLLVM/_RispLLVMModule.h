//
//  _RispLLVMModule.h
//  Risp
//
//  Created by closure on 6/1/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_MAC
#include "llvm-c/Core.h"
@interface _RispLLVMModule : NSObject
@property (nonatomic, assign, readonly) LLVMModuleRef module;
+ (instancetype)module:(LLVMModuleRef)llvmModule;
- (instancetype)initWithLLVMMoudle:(LLVMModuleRef)llvmModule;
@end
#endif