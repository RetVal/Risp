//
//  RispTrueExpression.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispTrueExpression.h>
#import <Risp/RispLiteralExpression.h>
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

@implementation RispTrueExpression
- (instancetype)init {
    if (self = [super init]) {
        _value = @YES;
    }
    return self;
}

- (id)value {
    return _value;
}

- (NSString *)description {
    return [[self value] description];
}

- (id)copyWithZone:(NSZone *)zone {
    RispTrueExpression *copy = [[RispTrueExpression alloc] initWithValue:_value];
    return copy;
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [super _descriptionWithIndentation:indentation desc:desc];
    [desc appendFormat:@"%@ - %@ %@\n", [self class], [self description], [self rispLocationInfomation]];
}
@end
