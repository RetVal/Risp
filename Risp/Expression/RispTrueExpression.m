//
//  RispTrueExpression.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispTrueExpression.h>
#import <Risp/RispLiteralExpression.h>

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
@end
