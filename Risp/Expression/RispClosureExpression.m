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

+ (void)_filterEnvironment:(RispClosureExpression *)closure {
    NSMutableDictionary *scope = (NSMutableDictionary *)[[closure environment] scope];
    [[[closure fnExpression] methods] enumerateObjectsUsingBlock:^(RispMethodExpression *method, NSUInteger idx, BOOL *stop) {
        [[method requiredParms] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [scope removeObjectForKey:obj];
        }];
        if ([method restParm]) {
            [scope removeObjectForKey:[method restParm]];
        }
    }];
}

- (id)initWithLexicalScopeEnvironment:(RispLexicalScope *)environment fnExpression:(RispFnExpression *)fnExpression {
    if (self = [super init]) {
        _environment = [[RispContext currentContext] mergeScope:environment];
        _fnExpression = fnExpression;
        [RispClosureExpression _filterEnvironment:self];
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
    RispLexicalScope *scope = [[RispContext currentContext] currentScope];
    RispClosureExpression *closure = [[RispClosureExpression alloc] initWithLexicalScopeEnvironment:scope fnExpression:[self fnExpression]];
    return closure;
}

- (id)applyTo:(RispVector *)arguments {
//    NSLog(@"%@", self);
    RispContext *context = [RispContext currentContext];
    id v = nil;
    BOOL push = NO;
    @try {
        
        RispVector *evalArguments = [RispRuntime map:arguments fn:^id(id object) {
            return [object eval];
        }];
        if (_environment) {
//            NSDictionary *env = [RispContext mergeScope:[context currentScope] withScope:_environment];
//            if (env) {
//                RispLexicalScope *scope = [[RispLexicalScope alloc] init];
//                [scope setScope:env];
////                NSLog(@"push closure env scope -> %@, org -> %@ ", scope, _environment);
//                [context pushScope:scope];
//                push = YES;
//            }
//            NSLog(@"push closure env scope -> %@ ", _environment);
            [context pushScope:_environment];
        }
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
    return [NSString stringWithFormat:@"%@", [_fnExpression description]];
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
