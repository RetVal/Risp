//
//  RispLiteralExpression.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispLiteralExpression.h>
#import <Risp/RispContext.h>

@implementation RispLiteralExpression
- (id)initWithValue:(id)value {
    if (self = [super init]) {
        _value = value;
    }
    return self;
}

- (id)value {
    return [[RispContext currentContext] currentScope][_value];
}

- (id)eval {
    return [self value];
}

- (NSString *)description {
    return _value;
}
@end
