//
//  RispNilExpression.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispNilExpression.h>

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
@end
