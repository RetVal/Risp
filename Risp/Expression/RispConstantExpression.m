//
//  RispConstantExpression.m
//  Risp
//
//  Created by closure on 5/13/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispConstantExpression.h"

@implementation RispConstantExpression
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context {
    id <RispSequence> seq = object;
    id v = [seq second];
    if (v == nil) {
        return [[RispNilExpression alloc] init];
    } else if ([v isEqual: @YES]) {
        return [[RispTrueExpression alloc] init];
    } else if ([v isEqual: @NO]) {
        return [[RispFalseExpression alloc] init];
    }
    
    if ([v isKindOfClass:[NSNumber class]]) {
        return [RispNumberExpression parser:v context:context];
    } else if ([v isKindOfClass:[NSString class]]) {
        return [RispStringExpression parser:v context:context];
    } else if ([v conformsToProtocol:NSProtocolFromString(@"RispSequence")] && [v count] == 0) {
        return [RispSequence empty];
    }
    return [[RispConstantExpression alloc] initWithValue:v];
}

- (id)initWithValue:(id)value {
    if (self = [super init]) {
        _constantValue = value;
    }
    return self;
}

- (id)eval {
    return _constantValue;
}
@end
