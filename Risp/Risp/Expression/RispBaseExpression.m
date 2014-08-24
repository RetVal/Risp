//
//  RispBaseExpression.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispBaseExpression.h"
#import "NSObject+RispMeta.h"

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

- (id)copyWithZone:(NSZone *)zone {
    RispBaseExpression *baseExpression = [[RispBaseExpression alloc] init];
    return baseExpression;
}

- (id)copyMetaFromObject:(id)object {
    return [super copyMetaFromObject:object];
}
@end
