//
//  RispFnExpression.m
//  Risp
//
//  Created by closure on 4/21/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispFnExpression.h>
#import <Risp/RispClosureExpression.h>

@implementation RispFnExpression

+ (RispFnExpression *)parse:(id<RispSequence>)form context:(RispContext *)context {
    //now (fn [args] body...) or (fn ([args] body...) ([args2] body2...) ...)
    RispFnExpression *fnExpr = [[RispFnExpression alloc] init];

    @try {
        [context pushScope];
        
        if ([[form second] isKindOfClass:[RispSymbol class]]) {
            fnExpr->_name = [form second];
            form = [[[form next] next] cons:[RispSymbol FN]];
        }
        
        //now (fn [args] body...) or (fn ([args] body...) ([args2] body2...) ...)
        
        if ([[form second] isKindOfClass:[RispVector class]]) {
            form = [[[RispList empty] cons:[form next]] cons:[RispSymbol FN]];
        }
        
        NSMutableArray *methodArray = [[NSMutableArray alloc] initWithCapacity:20];
        RispMethodExpression *variadicMethod = nil;
        for (id <RispSequence> seq = [form next]; seq; seq = [seq next]) {
            RispMethodExpression *method = [RispMethodExpression parser:[seq first] context:context fn:fnExpr static:YES];
            if (![method restParm]) {
                [methodArray addObject:method];
            } else if (variadicMethod == nil) {
                variadicMethod = method;
            } else {
                [NSException raise:RispIllegalArgumentException format:@"variadic method is already existing"];
            }
        }
        fnExpr->_methods = [RispVector listWithObjectsFromArrayNoCopy:methodArray];
        fnExpr->_variadicMethod = variadicMethod;
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        [context popScope];
    }
    return fnExpr;
}

- (RispMethodExpression *)methodForArguments:(RispVector *)arguments {
    return [self methodForCountOfArgument:[arguments count]];
}

- (RispMethodExpression *)methodForCountOfArgument:(NSUInteger)cntOfArguments {
    RispSequence *methods = _methods;
    if (_variadicMethod && cntOfArguments >= [_variadicMethod paramsCount]) {
        return _variadicMethod;
    } else {
        while (methods) {
            if (methods) {
                RispMethodExpression *method = [methods first];
                if (![method isVariadic] && cntOfArguments == [method paramsCount]) {
                    return method;
                }
            }
            methods = [methods next];
        }
    }
    return nil;
}

+ (void)_expandList:(id <RispSequence>)seq argumentSet:(NSMutableSet *)set {
    id <RispSequence> argumentsVector = seq;
    for (id x in argumentsVector) {
        if ([x conformsToProtocol:@protocol(RispSequence)]) {
            [self _expandList:x argumentSet:set];
        }
        [set addObject:x];
    }
}

+ (RispVector *)_analyzeMethod:(RispMethodExpression *)methodExpression context:(RispContext *)context {
    NSMutableSet *args = [[NSMutableSet alloc] init];
    [self _expandList:[methodExpression requiredParms] argumentSet:args];
    
    return nil;
}

- (id)eval {
    RispLexicalScope *scope = [[RispContext currentContext] currentScope];
    
    RispClosureExpression *closure = [[RispClosureExpression alloc] initWithLexicalScopeEnvironment:scope fnExpression:self];
    return closure;
}

- (NSString *)description {
    NSMutableString *desc = [[NSMutableString alloc] initWithString:@"(fn "];
    if (_name) {
        [desc appendFormat:@"%@ ", _name];
    }
    
    id <RispSequence> seq = _methods;
    while (seq) {
        RispMethodExpression *method = [seq first];
        if (method) {
            [desc appendFormat:@"%@", [method description]];
        }
        seq = [seq next];
    }
    
    [desc appendString:@")"];
    return desc;
}

- (id)applyTo:(RispVector *)arguments {
    return [[self methodForArguments:arguments] applyTo:arguments];
}

- (id)copyWithZone:(NSZone *)zone {
    RispFnExpression *copy = [[RispFnExpression alloc] init];
    copy->_methods = [_methods copy];
    copy->_name = [_name copy];
    copy->_variadicMethod = [_variadicMethod copy];
    return copy;
}

@end

@implementation RispFnExpression (BlockSupport)

+ (instancetype)blockWihObjcBlock:(id (^)(RispVector *))block variadic:(BOOL)isVariadic numberOfArguments:(NSUInteger)numberOfArguments {
    return [[RispFnExpression alloc] initWithBlock:block variadic:isVariadic numberOfArguments:numberOfArguments];
}

- (id)initWithBlock:(id (^)(RispVector *))block variadic:(BOOL)isVariadic numberOfArguments:(NSUInteger)numberOfArguments {
    RispFnExpression *fn = [[RispFnExpression alloc] init];
    RispMethodExpression *method = [[RispBlockExpression alloc] initWithBlock:block variadic:isVariadic numberOfArguments:numberOfArguments];
    if (isVariadic) {
        [fn setVariadicMethod:method];
    } else {
        [fn setMethods:[RispList listWithObjects:method, nil]];
    }
    return fn;
}
@end
