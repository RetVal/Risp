//
//  RispCodeGeneratorContext.m
//  Risp
//
//  Created by closure on 6/1/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispCodeGeneratorContext.h"

#import "_RispLLVMModule.h"

@interface RispCodeGeneratorContext ()
@property (nonatomic, strong, readonly) NSMutableArray *moduleStack;    // RispLLVMModule include
@end

@implementation RispCodeGeneratorContext

- (id)initWithRispContext:(RispContext *)rispContext llvmContext:(LLVMContextRef)llvmContext {
    if (self = [super init]) {
        _rispContext = rispContext;
        _llvmContext = llvmContext;
        _mainModule = LLVMModuleCreateWithNameInContext("main", _llvmContext);
        _moduleStack = [[NSMutableArray alloc] init];
        [self pushModule:_mainModule];
    }
    return self;
}

- (void)dealloc {
    _rispContext = nil;
    LLVMContextDispose(_llvmContext);
}

- (void)pushModule:(LLVMModuleRef)moduleToPush {
    [_moduleStack addObject:[_RispLLVMModule module:moduleToPush]];
}

- (void)popMoudle {
    [_moduleStack removeLastObject];
}

- (LLVMModuleRef)currentModule {
    return [[_moduleStack lastObject] module];
}

@end
