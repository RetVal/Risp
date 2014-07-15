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
#import "__RispLLVMFoundation.h"
@implementation RispNilExpression
- (instancetype)init {
    if (self = [super init]) {
        _value = [NSNull null];
    }
    return self;
}

- (id)value {
    return _value;
}

- (NSString *)description {
    return @"nil";
}

- (id)copyWithZone:(NSZone *)zone {
    RispNilExpression *copy = [[RispNilExpression alloc] initWithValue:_value];
    return copy;
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [RispAbstractSyntaxTree descriptionAppendIndentation:indentation desc:desc];
    [desc appendFormat:@"%@ - %@ %@\n", [self class], [self description], [self rispLocationInfomation]];
}
@end
