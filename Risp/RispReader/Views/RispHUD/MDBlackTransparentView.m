//
//  MDBlackTransparentView.m
//  Borderless Window
//
//  Created by Mark Douma on 12/15/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import "MDBlackTransparentView.h"


@implementation MDBlackTransparentView


- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
		
    }
    return self;
}

- (void)drawRect:(NSRect)frame {
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:6.0 yRadius:6.0];
	[[NSColor blackColor] set];
	[path fill];
}

@end
