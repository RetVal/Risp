//
//  RispFalseExpression.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispFalseExpression.h>

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
@end
