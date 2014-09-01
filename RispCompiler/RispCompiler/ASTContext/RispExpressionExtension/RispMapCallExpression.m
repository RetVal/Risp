//
//  RispMapCallExpression.m
//  RispCompiler
//
//  Created by closure on 8/27/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispMapCallExpression.h"

@implementation RispMapCallExpression
+ (RispBaseExpression *)parser:(id)object context:(RispContext *)context {
    if (![object isKindOfClass:[RispInvokeExpression class]]) {
        return nil;
    }
    return nil;
}
@end
