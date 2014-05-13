//
//  RispIRCodeGenerator.h
//  Risp
//
//  Created by closure on 5/8/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "llvm-c/Core.h"

@interface RispCodeGeneratorContext : NSObject
@property (nonatomic, strong, readonly) RispContext *rispContext;
@property (nonatomic, assign, readonly) LLVMContextRef *llvmContext;
@property (nonatomic, assign, readonly) LLVMModuleRef mainModule;

- (id)initWithRispContext:(RispContext *)rispContext llvmContext:(LLVMContextRef)llvmContext;

- (LLVMModuleRef)currentModule;
- (void)pushModule:(LLVMModuleRef)moduleToPush;
- (void)popMoudle;
@end

@protocol RispIRCodeGenerator <NSObject>
- (LLVMValueRef)generateCode:(RispContext *)context;
@end
