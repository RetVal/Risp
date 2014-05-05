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
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return method;
}

- (BOOL)isVariadic {
    return _restParm != nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", [_requiredParms description], [_bodyExpresion description]];
}

- (id)applyTo:(RispVector *)arguments {
    id v = nil;
    RispLexicalScope *scope = [[RispContext currentContext] currentScope];
    
    [_requiredParms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id v = arguments[idx];
        scope[obj] = v;
    }];
    
    for (id _expr in [_bodyExpresion exprs]) {
        v = [_expr eval];
    }
    return v;
}
@end
