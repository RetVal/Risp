//
//  NSString+Risp.m
//  Risp
//
//  Created by closure on 10/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "NSString+Risp.h"

@implementation NSString (Risp)
- (NSData *)toData {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}
@end
