//
//  RispNumberExpression.m
//  Risp
//
//  Created by closure on 4/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispNumberExpression.h"
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

@implementation RispNumberExpression
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context {
    return [[[RispNumberExpression alloc] initWithValue:object] copyMetaFromObject:object];
}

- (id)value {
    return _value;
}

- (NSString *)description {
    return [_value description];
}

- (id)copyWithZone:(NSZone *)zone {
    RispNumberExpression *copy = [[RispNumberExpression alloc] initWithValue:_value];
    return copy;
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [RispAbstractSyntaxTree descriptionAppendIndentation:indentation desc:desc];
    [desc appendFormat:@"%@ : %@ %@\n", [self class], [self description], [_value rispLocationInfomation]];
}
@end

@interface NSDecimalNumber (Compare)
- (NSNumber *)compareTo:(NSDecimalNumber *)n;
@end

@implementation NSDecimalNumber (Compare)

- (NSDecimalNumber *)compareTo:(NSNumber *)decimalNumber {
    NSComparisonResult result = [self compare:decimalNumber];
    return [[NSDecimalNumber alloc] initWithLong:result];
}

@end
