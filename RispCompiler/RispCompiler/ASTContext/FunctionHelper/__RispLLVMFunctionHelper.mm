//
//  __RispLLVMFunctionHelper.m
//  RispCompiler
//
//  Created by closure on 8/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <RispCompiler/__RispLLVMFoundation.h>
#import <RispCompiler/__RispLLVMFunctionHelper.h>
#import <RispCompiler/RispASTContext.h>
#import <RispCompiler/RispNameMangling.h>
#import <RispCompiler/RispNameManglingFunctionDescriptor.h>
#import <RispCompiler/RispScopeStack.h>
#import "RispASTContextPriv.h"

@implementation __RispLLVMFunctionHelper

+ (void)__argumentsBindingToFunction:(llvm::Value *)vec args:(RispVector *)args function:(llvm::Function *)function binding:(llvm::SmallVector<llvm::Value *, 8> &)binding isVariadic:(BOOL)isVariadic context:(RispASTContext *)context {
    __RispLLVMFoundation *CGM = [context CGM];
    BOOL isClosure = [context _isClosure:function];
    if (isClosure) {
        return;
    }
    NSUInteger idx = 0;
    RispVector *ins = [RispVector empty];
    for (id arg __unused in args) {
        binding.push_back([CGM emitMessageCall:vec selector:@selector(objectAtIndexedSubscript:) arguments:{llvm::ConstantInt::get([CGM intType], idx)} instance:ins]);
        idx++;
    }
    return;
}

+ (llvm::Function *)__functionWithMangling:(RispNameMangling *)mangling fromName:(NSString *)funcName method:(RispMethodExpression *)method arguments:(RispVector *)arguments context:(RispASTContext *)context {
    if ([funcName isEqualToString:@"RispAnonymousFunction2"]) {
        NSLog(@"");
    }
    NSString *name = nil;
    if (arguments == nil) {
        name = funcName;
    } else {
        RispNameManglingFunctionDescriptor *descriptor = [mangling functionManglingWithName:funcName arguments:arguments];
        name = [descriptor functionName];
    }
    llvm::Value *funcValue = [[context currentStack] objectForKey:[[RispSymbolExpression alloc] initWithSymbol:[RispSymbol named:name]]];
    llvm::Function *func = nullptr;
    if (funcValue != nullptr) {
        func = llvm::dyn_cast<llvm::Function>(funcValue);
    } else {
        __RispLLVMFoundation *CGM = [context CGM];
        func = [CGM module]->getFunction([name UTF8String]);
        if (func == nullptr) {
            NSLog(@"");
        }
    }
    return func;
}

@end