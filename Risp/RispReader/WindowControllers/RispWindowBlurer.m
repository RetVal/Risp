//
//  RispWindowBlurer.m
//  Risp
//
//  Created by closure on 4/26/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispWindowBlurer.h"

@implementation RispWindowBlurer
typedef void * CGSConnectionID;
typedef void * CGSConnection;
typedef void * CGSWindowID;
extern OSStatus CGSNewConnection(const void **attributes, CGSConnection * id);
typedef void *CGSWindowFilterRef;
extern CGError CGSNewCIFilterByName(CGSConnection cid, CFStringRef filterName, CGSWindowFilterRef *outFilter);
extern CGError CGSAddWindowFilter(CGSConnection cid, CGSWindowID wid, CGSWindowFilterRef filter, int flags);
extern CGError CGSSetCIFilterValuesFromDictionary(CGSConnection cid, CGSWindowFilterRef filter, CFDictionaryRef filterValues);

+ (void)enableBlurForWindow:(NSWindow *)window
{
    
    CGSConnectionID _myConnection;
    CGSWindowFilterRef __compositingFilter;
    
    int __compositingType = 1; // Apply filter to contents underneath the window, then draw window normally on top
    
    /* Make a new connection to CoreGraphics, alternatively you could use the main connection*/
    
    CGSNewConnection(NULL , &_myConnection);
    
    /* The following creates a new CoreImage filter, then sets its options with a dictionary of values*/
    
    CGSNewCIFilterByName (_myConnection, (CFStringRef)@"CIGaussianBlur", &__compositingFilter);
    NSDictionary *optionsDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:20.0] forKey:@"inputRadius"];
    CGSSetCIFilterValuesFromDictionary(_myConnection, __compositingFilter, (__bridge CFDictionaryRef)optionsDict);
    
    /* Now just switch on the filter for the window */
    
    CGSAddWindowFilter(_myConnection, (CGSWindowID)[window windowNumber], __compositingFilter, __compositingType );
}
@end
