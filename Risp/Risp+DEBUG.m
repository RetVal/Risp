//
//  Risp+DEBUG.m
//  Risp
//
//  Created by closure on 5/26/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "Risp+DEBUG.h"

@implementation Risp (Debug)
+ (NSString *)decriptionForExpression:(id <RispExpression>)expression {
    return [expression description];
}

+ (void)show:(id)object {
    NSLog(@"%@", object);
    return;
}
@end
