//
//  RispSelectorExpression.m
//  Risp
//
//  Created by closure on 8/22/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispSelectorExpression.h"

@implementation RispSelectorExpression
+ (RispSelectorExpression *)parser:(id)object context:(RispContext *)context {
    if (!object || ![object isKindOfClass:[RispSymbol class]]) {
        return nil;
    }
    return [[RispSelectorExpression alloc] initWithValue:object];
}

- (id)eval {
    return [super literalValue];
}

- (id)value {
    return [super literalValue];
}

- (NSString *)description {
    return [super description];
}
@end
