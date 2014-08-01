//
//  ASUserNotificationBannerBackgroundView.m
//
//  Created by Frank Gregor on 17.05.13.
//  Copyright (c) 2013 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2013 Frank Gregor, <phranck@cocoanaut.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the “Software”), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "ASUserNotificationBannerBackgroundView.h"


static NSColor *gradientTopColor, *gradientBottomColor;
static NSGradient *backgroundGradient;
static CGFloat bannerRadius;


@implementation ASUserNotificationBannerBackgroundView

+ (void)initialize {
	gradientTopColor = [NSColor colorWithCalibratedWhite:0.975 alpha:0.950];
	gradientBottomColor = [NSColor colorWithCalibratedWhite:0.820 alpha:0.950];
	backgroundGradient = [[NSGradient alloc] initWithStartingColor:gradientTopColor endingColor:gradientBottomColor];
	bannerRadius = 5.0;
}

- (void)drawRect:(NSRect)dirtyRect {
	NSRect bounds = [self bounds];
	NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRoundedRect:bounds xRadius:bannerRadius yRadius:bannerRadius];
	[backgroundGradient drawInBezierPath:backgroundPath angle:-90];
}

@end
