//
//  RispCompilerExceptionLocation.m
//  RispCompiler
//
//  Created by closure on 8/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <RispCompiler/RispCompilerExceptionLocation.h>
#import <RispCompiler/RispCompilerExceptionManager.h>

NSString * RispCompilerReturnTypeException = @"RispCompiler.Exception.ReturnType";

@implementation RispCompilerExceptionLocation
+ (void)exceptionLocationWithExpression:(RispBaseExpression *)expression exception:(NSException *)exception {
    [[RispCompilerExceptionManager defaultManager] addExceptionLocation:[[RispCompilerExceptionLocation alloc] initWithExpression:expression exception:exception]];
}

- (instancetype)initWithExpression:(RispBaseExpression *)expression exception:(NSException *)exception {
    if (self = [super init]) {
        _expression = expression;
        _exception = exception;
    }
    return self;
}
@end
