//
//  RispSymbolExpression+Meta.m
//  RispCompiler
//
//  Created by closure on 8/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispSymbolExpression+Meta.h"

@implementation RispSymbolExpression (Meta)
- (BOOL)isClass {
    return [[self meta][@"is-class"] boolValue];
}

- (void)setIsClass:(BOOL)isClass {
    [self withMeta:@(isClass) forKey:@"is-class"];
}

@end
