//
//  RispInvokeExpression.m
//  Risp
//
//  Created by closure on 4/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispInvokeExpression.h"

@implementation RispInvokeExpression
+ (RispInvokeExpression *)parser:(id <RispSequence>)form context:(RispContext *)context {
    if([context status] != RispContextEval)
        [context setStatus:RispContextExpression];
    id <RispExpression> fexpr = [RispBaseParser analyze:context form:[form first]];
//    PersistentVector args = PersistentVector.EMPTY;
//    for(ISeq s = RT.seq(form.next()); s != null; s = s.next())
//    {
//        args = args.cons(analyze(context, s.first()));
//    }
    NSMutableArray *args = [[NSMutableArray alloc] init];
    for (id <RispSequence> s = [form next]; s; s = [s next]) {
        [args addObject:[RispBaseParser analyze:context form:[s first]]];
    }
    
    return [[RispInvokeExpression alloc] initWithExpression:fexpr arguments:[RispVector listWithObjectsFromArrayNoCopy:args]];
}

- (id)initWithExpression:(id <RispExpression>)fnexpression arguments:(RispVector *)arguments {
    if (!fnexpression)
        return nil;
    if (self = [super init]) {
        _fexpr = fnexpression;
        _arguments = arguments;
    }
    return self;
}

- (id)eval {
#warning fixme
    [[RispContext currentContext] pushScope];
    // binding scope
    
    RispLexicalScope *scope = [[RispContext currentContext] currentScope];
    
    id fn = nil;
    if (![_fexpr isKindOfClass:[RispFnExpression class]]) {
        id sym = [_fexpr eval];
        if (![sym isKindOfClass:[RispFnExpression class]]) {
            [NSException raise:RispRuntimeException format:@"%@ is not a fn", _fexpr];
        }
        if ([sym isMemberOfClass:[RispSymbol class]]) {
            fn = scope[sym];
            if (![fn isKindOfClass:[RispFnExpression class]]) {
                [NSException raise:RispRuntimeException format:@"%@ is not a fn", sym];
            }
        }
        fn = fn ? : sym;
    } else {
        fn = _fexpr;
    }
    NSLog(@"invoke %@", fn);
    NSLog(@"%@", _arguments);
    
    RispMethodExpression *method = [fn methodForArguments:_arguments];
    
    RispVector *evalArguments = [RispRuntime map:_arguments fn:^id(id object) {
        return [object eval];
    }];
    
    id v = [method applyTo:evalArguments];
    [[RispContext currentContext] popScope];
    return v;
}
@end
