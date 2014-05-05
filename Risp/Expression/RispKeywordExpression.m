//
//  RispKeywordExpression.m
//  Risp
//
//  Created by closure on 4/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispKeywordExpression.h>

@implementation RispKeywordExpression
- (id)initWithKeyword:(RispKeyword *)keyword {
    if (self = [super initWithValue:keyword]) {
    }
    return self;
}

- (id)value {
    return _value;
}

- (NSString *)description {
    return [_value description];
}
@end
