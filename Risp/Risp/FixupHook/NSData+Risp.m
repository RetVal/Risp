//
//  NSData+Risp.m
//  Risp
//
//  Created by closure on 10/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "NSData+Risp.h"

@implementation NSData (Risp)
- (NSString *)toString {
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}
@end
