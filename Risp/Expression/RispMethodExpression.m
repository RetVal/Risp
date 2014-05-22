//
//  RispMethodExpression.m
//  Risp
//
//  Created by closure on 4/21/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispMethodExpression.h>
#import <Risp/RispVector.h>
#import <Risp/RispSymbol+BIF.h>
#import <Risp/RispBodyExpression.h>

@interface RispMethodExpression () {
@private
    RispBodyExpression *_bodyExpresion;
}

@end

@implementation RispMethodExpression
+ (RispMethodExpression *)parser:(id<RispSequence>)form context:(RispContext *)context fn:(RispFnExpression *)fn static:(BOOL)isStatic {
    //([args] body...)
    RispVector *parms = [form first];
    id <RispSequence> body = [form next];
    RispMethodExpression *method = [[RispMethodExpression alloc] init];
    @try {
        RispCompilerStatus status = RispCompilerStatusREQ;
        for (NSUInteger idx = 0; idx < [parms count]; idx++) {
            if (![[parms nth:idx] isKindOfClass:[RispSymbol class]]) {
                [NSException raise:RispIllegalArgumentException format:@"fn params must be Symbols"];
            }
            RispSymbol *p = [parms nth:idx];
            if ([p isEqualTo:[RispSymbol AMP]]) {
                if (status == RispCompilerStatusREQ) {
                    status = RispCompilerStatusREST;    // it must be the last second symbol in params vector
                } else {
                    [NSException raise:RispIllegalArgumentException format:@"Invalid parameter list"];
                }
            } else if (status == RispCompilerStatusREST) {
                status = RispCompilerStatusDONE;
                method->_restParm = p;
            }
        }
        method->_requiredParms = parms;
        method->_bodyExpresion = [RispBodyExpression parser:body context:context];
        method->_localBinding = [context currentScope];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return method;
}

- (NSInteger)paramsCount {
    return [self isVariadic] ? [_requiredParms count] - 1 : [_requiredParms count];
}

- (BOOL)isVariadic {
    return _restParm != nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(%@ %@)", [_requiredParms description], [_bodyExpresion description]];
}

- (id)applyTo:(RispVector *)arguments {
    id v = nil;
    @try {
        [[RispContext currentContext] pushScope];
        RispLexicalScope *scope = [[RispContext currentContext] currentScope];
        if (_localBinding) {
            NSArray *keys = [_localBinding keys];
            for (id k in keys) {
                scope[k] = _localBinding[k];
            }
        }
        
        if (![self isVariadic]) {
            [_requiredParms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                id v = arguments[idx];
                scope[obj] = v;
            }];
        } else {
            NSInteger limit = [self paramsCount] - 1;
            [_requiredParms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (idx < limit) {
                    id v = arguments[idx];
                    scope[obj] = v;
                } else {
                    *stop = YES;
                }
            }];
            RispList *seq = [RispList listWithObjectsFromArray:[[arguments drop:@(limit)] array]];
            scope[_restParm] = seq;
        }
        for (id _expr in [_bodyExpresion exprs]) {
            v = [_expr eval];
        }

    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        [[RispContext currentContext] popScope];
    }
    return v;
}

- (id)copyWithZone:(NSZone *)zone {
    RispMethodExpression *copy = [[RispMethodExpression alloc] init];
    copy->_statics = _statics;
    copy->_argstypes = [_argstypes copy];
    copy->_bodyExpresion = [_bodyExpresion copy];
    copy->_localBinding = [_localBinding copy];
    copy->_prim = [_prim copy];
    copy->_requiredParms = [_requiredParms copy];
    copy->_restParm = [_restParm copy];
    return copy;
}
@end
