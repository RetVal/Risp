//
//  RispBlockExpression.m
//  Risp
//
//  Created by closure on 5/8/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispBlockExpression.h"

@interface RispBlockExpression () {
    @private
    BOOL _variadic;
}

@end

@implementation RispBlockExpression
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context {
    return [super parser:object context:context];
}

+ (id<RispExpression>)blockWihObjcBlock:(id (^)(RispVector *arguments))block variadic:(BOOL)isVariadic numberOfArguments:(NSUInteger)numberOfArguments {
    return [[RispBlockExpression alloc] initWithBlock:block variadic:isVariadic numberOfArguments:numberOfArguments];
}

- (id)initWithBlock:(id (^)(RispVector *arguments))block variadic:(BOOL)isVariadic numberOfArguments:(NSUInteger)numberOfArguments {
    if (self = [super init]) {
        _block = block;
        _variadic = isVariadic;
        _numberOfArguments = numberOfArguments;
    }
    return self;
}

- (id)applyTo:(RispVector *)arguments {
    if (!_block) return nil;
    return _block(arguments);
}

- (BOOL)isVariadic {
    return _variadic;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", NSStringFromClass([self class]), self];
}

- (NSInteger)paramsCount {
    return _numberOfArguments;
}
@end
