//
//  RispCodeGeneratorContext.h
//  Risp
//
//  Created by closure on 6/1/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "llvm-c/Core.h"

@class RispContext;
@interface RispCodeGeneratorContext : NSObject
@property (nonatomic, strong, readonly) RispContext *rispContext;
@property (nonatomic, assign, readonly) LLVMContextRef llvmContext;
@property (nonatomic, assign, readonly) LLVMModuleRef mainModule;

- (id)initWithRispContext:(RispContext *)rispContext llvmContext:(LLVMContextRef)llvmContext;

- (LLVMModuleRef)currentModule;
- (void)pushModule:(LLVMModuleRef)moduleToPush;
- (void)popMoudle;
@end
