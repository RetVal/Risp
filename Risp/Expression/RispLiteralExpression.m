//
//  RispLiteralExpression.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispLiteralExpression.h>
#import <Risp/RispContext.h>
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

@implementation RispLiteralExpression
- (id)initWithValue:(id)value {
    if (self = [super init]) {
        _value = value;
    }
    return self;
}

- (id)value {
    RispLexicalScope *scope = [[RispContext currentContext] currentScope];
    return scope[_value];
}

- (id)literalValue {
    return _value;
}

- (id)eval {
    return [self value];
}

- (NSString *)description {
    return [_value description];
}

- (id)copyWithZone:(NSZone *)zone {
    RispLiteralExpression *copy = [[RispLiteralExpression alloc] initWithValue:_value];
    return copy;
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [super _descriptionWithIndentation:indentation desc:desc];
    [desc appendFormat:@"%@ : %@\n", [self class], [self description]];
}
@end
