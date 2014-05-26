//
//  RispVectorExpression.m
//  Risp
//
//  Created by closure on 4/21/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispVectorExpression.h>
#import <Risp/RispCompiler.h>
#import <Risp/RispBaseParser.h>
#import <Risp/RispBaseExpression.h>
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

@interface RispVectorExpression () {
    @private
    RispVector *_vector;
}

@end

@implementation RispVectorExpression
+ (RispVectorExpression *)parse:(RispVector *)form context:(RispContext *)context {
    __block BOOL constant = YES;
    NSMutableArray *argsArray = [[NSMutableArray alloc] init];
    [form enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id expr = [RispBaseParser analyze:context form:obj];
        [argsArray addObject:expr];
        if (![expr isKindOfClass:[RispLiteralExpression class]]) {
            constant = NO;
        }
    }];

    RispVector *args = [[RispVector alloc] initWithArrayNoCopy:argsArray];
    RispVectorExpression *retExpr = [[RispVectorExpression alloc] initWithVector:args];
    return retExpr;
}

- (id)initWithVector:(RispVector *)vector {
    if (self = [super init]) {
        _vector = vector;
    }
    return self;
}

- (RispVector *)vector {
    return _vector;
}

- (id)eval {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [_vector enumerateObjectsUsingBlock:^(id <RispExpression> obj, NSUInteger idx, BOOL *stop) {
        [array addObject:[obj eval]];
    }];
    return [[RispVector alloc] initWithArrayNoCopy:array];
}

- (NSString *)description {
    return [_vector description];
}

- (id)copyWithZone:(NSZone *)zone {
    RispVectorExpression *copy = [[RispVectorExpression alloc] initWithVector:_vector];
    return copy;
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [super _descriptionWithIndentation:indentation desc:desc];
    [desc appendFormat:@"%@\n", [self class]];
    [_vector enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [desc appendString:[RispAbstractSyntaxTree descriptionAppendIndentation:indentation + 1 forObject:obj]];
    }];
}
@end
