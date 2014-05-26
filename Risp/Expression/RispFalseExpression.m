//
//  RispFalseExpression.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispFalseExpression.h>
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

@implementation RispFalseExpression
- (instancetype)init {
    if (self = [super init]) {
        _value = @NO;
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
    RispFalseExpression *copy = [[RispFalseExpression alloc] initWithValue:_value];
    return copy;
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [super _descriptionWithIndentation:indentation desc:desc];
    [desc appendFormat:@"%@ - %@\n", [self class], [self description]];
}
@end
