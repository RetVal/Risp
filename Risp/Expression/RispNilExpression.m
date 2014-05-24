//
//  RispNilExpression.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispNilExpression.h>
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

@implementation RispNilExpression
- (instancetype)init {
    if (self = [super init]) {
        _value = nil;
    }
    return self;
}

- (id)value {
    return _value;
}

- (NSString *)description {
    return @"null";
}

- (id)copyWithZone:(NSZone *)zone {
    RispNilExpression *copy = [[RispNilExpression alloc] initWithValue:_value];
    return copy;
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [super _descriptionWithIndentation:indentation desc:desc];
    [desc appendFormat:@"%@ - %@\n", [self class], [self description]];
}
@end
