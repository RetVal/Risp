//
//  NSDecimalNumber+Math.m
//  Risp
//
//  Created by closure on 5/30/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "NSDecimalNumber+Math.h"

@implementation NSDecimalNumber (Math)
- (id)mod:(NSDecimalNumber *)divisor {
    NSDecimalNumber *quotient = [self decimalNumberByDividingBy:divisor withBehavior:[NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO]];
    NSDecimalNumber *subtractAmount = [quotient decimalNumberByMultiplyingBy:divisor];
    NSDecimalNumber *remainder = [self decimalNumberBySubtracting:subtractAmount];
    return remainder;
}
@end
