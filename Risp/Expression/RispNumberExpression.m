//
//  RispNumberExpression.m
//  Risp
//
//  Created by closure on 4/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispNumberExpression.h"

@implementation RispNumberExpression
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context {
    return [[RispNumberExpression alloc] initWithValue:object];
}

- (id)value {
    return _value;
}

- (NSString *)description {
    return [_value description];
}
@end
