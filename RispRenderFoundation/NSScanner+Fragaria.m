//
//  NSScanner+Fragaria.m
//  Fragaria
//
//  Created by Jonathan on 12/08/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import "NSScanner+Fragaria.h"


@implementation  NSScanner (Fragaria)

/*
 
 RispRenderFoundation_setScanLocation:
 
 */
- (void)RispRenderFoundation_setScanLocation:(NSUInteger)idx 
{
    /*
     
     NSScanner raises if the index is beyond the end of the string.
     
     */
    NSUInteger maxIndex = [[self string] length];
	if (idx > maxIndex) {
        NSLog(@"Invalid scan location %lu > max of %lu", (long)idx, (long)maxIndex);
		idx = maxIndex;
	}
	
	[self setScanLocation:idx];
}
@end
