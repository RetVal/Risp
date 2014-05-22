//
//  RispKeywordExpression.m
//  Risp
//
//  Created by closure on 4/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispKeywordExpression.h>

@implementation RispKeywordExpression
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context {
    return [[RispKeywordExpression alloc] initWithKeyword:object];
}

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

- (id)copyWithZone:(NSZone *)zone {
    RispKeywordExpression *copy = [[RispKeywordExpression alloc] initWithValue:_value];
    return copy;
}
@end
