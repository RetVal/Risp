//
//  RispBaseExpression.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispBaseExpression.h"

@implementation RispBaseExpression
+ (id <RispExpression>)parser:(id)object context:(RispContext *)context {
    return nil;
}

- (id)eval {
    return nil;
}

- (NSString *)description {
    return [[self eval] description];
}
@end
