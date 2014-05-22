//
//  RispStringExpression.m
//  Risp
//
//  Created by closure on 4/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispStringExpression.h"

@implementation RispStringExpression
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context {
    return [[RispStringExpression alloc] initWithValue:object];
}

- (id)value {
    return _value;
}

- (NSString *)description {
    return _value;
}

- (id)copyWithZone:(NSZone *)zone {
    RispStringExpression *copy = [[RispStringExpression alloc] initWithValue:_value];
    return copy;
}
@end
