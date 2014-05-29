//
//  MDBorderlessWindow.m
//  Borderless Window
//
//  Created by Mark Douma on 6/19/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import "MDBorderlessWindow.h"


@implementation MDBorderlessWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation {
	
	if (self = [super initWithContentRect:contentRect
								styleMask:NSBorderlessWindowMask
								  backing:NSBackingStoreBuffered defer:deferCreation]) {
		[self setAlphaValue:0.75];
		[self setOpaque:NO];
		[self setExcludedFromWindowsMenu:NO];
		[self setBackgroundColor:[NSColor clearColor]];
        [self setLevel:NSFloatingWindowLevel];
	}
	return self;
}




@end
