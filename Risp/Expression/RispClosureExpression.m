//
//  RispClosureExpression.m
//  Risp
//
//  Created by closure on 5/22/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispClosureExpression.h"
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

@implementation RispClosureExpression
- (id)initWithLexicalScopeEnvironment:(RispLexicalScope *)environment fnExpression:(RispFnExpression *)fnExpression {
    if (self = [super init]) {
        _environment = [[RispContext currentContext] mergeScope:environment];
        _fnExpression = fnExpression;
        if (0 == [[_environment scope] count]) {
            _environment = nil;
        }
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
    NSLog(@"%@", self);
    RispContext *context = [RispContext currentContext];
    id v = nil;
    BOOL push = NO;
    @try {
        if (_environment) {
            NSDictionary *env = [RispContext mergeScope:[context currentScope] withScope:_environment];
            if (env) {
                RispLexicalScope *scope = [[RispLexicalScope alloc] init];
                [scope setScope:env];
                [context pushScope:scope];
                push = YES;
            }
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
        if (push) {
            [context popScope];
        }
    }
    return v;
}

- (NSString *)description {
    return [_fnExpression description];
}

- (RispMethodExpression *)methodForCountOfArgument:(NSUInteger)cntOfArguments {
    return [_fnExpression methodForCountOfArgument:cntOfArguments];
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [RispAbstractSyntaxTree descriptionAppendIndentation:indentation desc:desc];
    [desc appendFormat:@"%@\n", [self className]];
    [_fnExpression _descriptionWithIndentation:indentation + 1 desc:desc];
    if (_environment)
        [desc appendFormat:@"%@\n", _environment];
}
@end
