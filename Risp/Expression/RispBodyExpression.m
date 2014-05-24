//
//  RispBodyExpression.m
//  Risp
//
//  Created by closure on 4/22/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispBodyExpression.h"
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

@implementation RispBodyExpression
+ (RispBodyExpression *)parser:(id<RispSequence>)form context:(RispContext *)context {
    if ([[form first] isEqualTo:[RispSymbol DO]]) {
        form = [form next];
    }
    NSMutableArray *exprs = [[NSMutableArray alloc] init];
    RispContextStatus status = [context status];
    for (; form; form = [form next]) {
        RispBaseExpression *expr = nil;
        if (([context status] != RispContextEval && ([context status] == RispContextStatement || [form next]))) {
            [context setStatus:RispContextStatement];
            expr = [RispBaseParser analyze:context form:[form first]];
        } else {
            expr = [RispBaseParser analyze:context form:[form first]];
        }
        [exprs addObject:expr];
    }
    [context setStatus:status];
    return [[RispBodyExpression alloc] initWithExpressions:[RispVector listWithObjectsFromArrayNoCopy:exprs]];
}

- (id)initWithExpressions:(RispVector *)exprs {
    if (self = [super init]) {
        _exprs = exprs;
    }
    return self;
}

- (id)eval {
    __block id result = nil;
    [_exprs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = [obj eval];
    }];
    return result;
}

- (NSString *)description {
    __block id result = nil;
    [_exprs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = [obj description];
    }];
    return result;
}

- (id)copyWithZone:(NSZone *)zone {
    RispBodyExpression *copy = [[RispBodyExpression alloc] init];
    copy->_exprs = [_exprs copy];
    return copy;
}
@end
