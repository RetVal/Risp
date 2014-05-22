//
//  RispClosureExpression.m
//  Risp
//
//  Created by closure on 5/22/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispClosureExpression.h"

@implementation RispClosureExpression
- (id)initWithLexicalScopeEnvironment:(RispLexicalScope *)environment {
    if (self = [super init]) {
        
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    RispClosureExpression *copy = [[RispClosureExpression alloc] initWithLexicalScopeEnvironment:_environment fnExpression:_fnExpression];
    return copy;
}
@end
