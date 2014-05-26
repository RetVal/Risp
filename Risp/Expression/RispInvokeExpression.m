//
//  RispInvokeExpression.m
//  Risp
//
//  Created by closure on 4/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispInvokeExpression.h"
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

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

- (NSString *)description {
    NSMutableArray *descs = [[NSMutableArray alloc] init];
    [descs addObject:_fexpr];
    [descs addObjectsFromArray:[_arguments array]];
    for (NSUInteger idx = 0; idx < [descs count]; idx ++) {
        descs[idx] = [descs[idx] description];
    }
    return [descs componentsJoinedByString:@" "];
}

- (id)eval {
    [[RispContext currentContext] pushScope];
    // binding scope
    
    RispLexicalScope *scope = [[RispContext currentContext] currentScope];
    
    id fn = nil;
    if (![_fexpr conformsToProtocol:@protocol(RispFnProtocol)]) {
        id sym = [_fexpr eval];
        if (![sym conformsToProtocol:@protocol(RispFnProtocol)]) {
            [[RispContext currentContext] popScope];
            [NSException raise:RispRuntimeException format:@"%@ is not a fn", _fexpr];
        }
        if ([sym isMemberOfClass:[RispSymbol class]]) {
            fn = scope[sym];
            if (![fn conformsToProtocol:@protocol(RispFnProtocol)]) {
                [[RispContext currentContext] popScope];
                [NSException raise:RispRuntimeException format:@"%@ is not a fn", sym];
            }
        }
        fn = fn ? : sym;
    } else {
        fn = _fexpr;
    }
//    NSLog(@"invoke %@", fn);
//    NSLog(@"%@", _arguments);
    BOOL isClosure = [fn isKindOfClass:[RispClosureExpression class]];
    
    id v = nil;
    @try {
        
        if (isClosure) {
            RispClosureExpression *closure = fn;
            v = [closure applyTo:_arguments];
        } else {
            RispMethodExpression *method = [fn methodForArguments:_arguments];
            RispVector *evalArguments = [RispRuntime map:_arguments fn:^id(id object) {
                return [object eval];
            }];
            v = [method applyTo:evalArguments];
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
    RispInvokeExpression *copy = [[RispInvokeExpression alloc] initWithExpression:_fexpr arguments:_arguments];
    return copy;
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [super _descriptionWithIndentation:indentation desc:desc];
    [desc appendFormat:@"%@\n", [self class]];
    NSMutableArray *descs = [[NSMutableArray alloc] init];
    [descs addObject:_fexpr];
    [descs addObjectsFromArray:[_arguments array]];
    indentation += 1;
    for (NSUInteger idx = 0; idx < [descs count]; idx ++) {
        [descs[idx] _descriptionWithIndentation:indentation desc:desc];
    }
}

@end
