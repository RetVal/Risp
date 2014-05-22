//
//  RispClosureExpression.m
//  Risp
//
//  Created by closure on 5/22/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispClosureExpression.h"

@implementation RispClosureExpression
- (id)initWithLexicalScopeEnvironment:(RispLexicalScope *)environment fnExpression:(RispFnExpression *)fnExpression {
    if (self = [super init]) {
        _environment = environment;
        _fnExpression = fnExpression;
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    RispClosureExpression *copy = [[RispClosureExpression alloc] initWithLexicalScopeEnvironment:_environment fnExpression:_fnExpression];
    return copy;
}

- (id)eval {
    return self;
}

- (id)applyTo:(RispVector *)arguments {
    RispContext *context = [RispContext currentContext];
    id v = nil;
    @try {
        if (_environment) {
            [context pushScopeWithMergeScope:_environment];
        }
        RispVector *evalArguments = [RispRuntime map:arguments fn:^id(id object) {
            return [object eval];
        }];
        RispMethodExpression *method = [_fnExpression methodForCountOfArgument:[evalArguments count]];
        v = [method applyTo:evalArguments];
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        if (_environment) {
            [context popScope];
        }
    }
    return v;
}

- (NSString *)description {
    return [_fnExpression description];
}
@end
