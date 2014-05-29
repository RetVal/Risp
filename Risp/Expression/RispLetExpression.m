//
//  RispLetExpression.m
//  Risp
//
//  Created by closure on 5/25/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispLetExpression.h"
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

@implementation RispLetExpression
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context {
    if (![object conformsToProtocol:@protocol(RispSequence)]) {
        [NSException raise:RispIllegalArgumentException format:@"%@ is not a seq", object];
    }
    
    if ([object count] > 3) {
        [NSException raise:RispIllegalArgumentException format:@"too many params in %@", object];
    }
    
    id <RispSequence> seq = object;
    RispVectorExpression *bindingExpression = [RispBaseParser analyze:[context status] == RispContextEval ? context : ([context setStatus:RispContextExpression] , context) form:[seq second]];
    if (![bindingExpression isKindOfClass:[RispVectorExpression class]]) {
        [NSException raise:RispIllegalArgumentException format:@"%@ is not a vector", [seq second]];
    }
    if ([[bindingExpression vector] count] & 0x1) {
        [NSException raise:RispIllegalArgumentException format:@"%@ should be even", bindingExpression];
    }
    seq = [[seq next] next];
    RispBaseExpression *bodyExpression = nil;
    if (seq) {
        if ([seq conformsToProtocol:@protocol(RispSequence)]) {
            seq = [seq first];
        }
        bodyExpression = [RispBaseParser analyze:context form:seq];
//        bodyExpression = [RispBodyExpression parser:seq context:context];
    }
    RispLetExpression *letExpression = [[RispLetExpression alloc] initWithBindingExpression:bindingExpression bodyExpression:bodyExpression];
    return letExpression;
}

- (id)initWithBindingExpression:(RispVectorExpression *)bindingExpression bodyExpression:(RispBaseExpression *)bodyExpression {
    if (self = [super init]) {
        _bindingExpression = bindingExpression;
        _expression = bodyExpression;
    }
    return self;
}

- (id)eval {
    id v = nil;
    RispContext *context = [RispContext currentContext];
    @try {
        if (_expression) {
            RispLexicalScope *scope = [context pushScope];
            RispVector *vector = [_bindingExpression vector];
            [vector enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (idx & 0x1) return ;
                if ([obj isMemberOfClass:[RispLiteralExpression class]]) {
                    obj = [obj literalValue];
                } else if ([obj isKindOfClass:[RispVectorExpression class]]) {
                    [NSException raise:RispRuntimeException format:@"unsupport Pattern Matching"];
                } else {
                    [NSException raise:RispIllegalArgumentException format:@"first must be a symbol or a vector"];
                }
                id value = vector[idx + 1];
                id v = [value eval];
                if ([v isKindOfClass:[RispFnExpression class]]) {
                    v = [v eval]; // fn -> closure
                }
                
                if ([obj isKindOfClass:[RispSymbol class]]) {
                    scope[obj] = v;
                } else {
                    [NSException raise:RispRuntimeException format:@"bug in risp-let"];
                }
            }];
            v = [_expression eval];
        }
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        if (_expression) {
            [context popScope];
        }
    }
    return v;
}

+ (RispSymbol *)speicalKey {
    return [RispSymbol named:@"let"];
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [RispAbstractSyntaxTree descriptionAppendIndentation:indentation desc:desc];
    [desc appendFormat:@"%@\n", [self className]];
    [_bindingExpression _descriptionWithIndentation:indentation + 1 desc:desc];
    [_expression _descriptionWithIndentation:indentation + 1 desc:desc];
}
@end
