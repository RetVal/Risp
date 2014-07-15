//
//  ASUserNotification.m
//
//  Created by Frank Gregor on 16.05.13.
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

#import <objc/runtime.h>

#import "ASUserNotification.h"


/// names for notifications
NSString *const ASUserNotificationHasBeenPresentedNotification = @"ASUserNotificationHasBeenPresentedNotification";


@interface ASUserNotification () {
	ASUserNotificationFeature *_feature;
}
@property id ASUserNotificationInstance;
@end

@implementation ASUserNotification

- (instancetype)init {
	if (NSClassFromString(@"NSUserNotification")) {
		_ASUserNotificationInstance = [[NSUserNotification alloc] init];
	}

	else {
		self = [super init];
		if (self) {
			_ASUserNotificationInstance = self;
			_feature = [ASUserNotificationFeature new];

			_title = @"";
			_subtitle = @"";
			_informativeText = @"";
			_hasActionButton = NO;
			_actionButtonTitle = nil;
			_otherButtonTitle = nil;
			_presented = NO;
			_soundName = nil;
			_activationType = ASUserNotificationActivationTypeNone;
			_userInfo = [[NSDictionary alloc] init];

			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			[nc addObserverForName:ASUserNotificationHasBeenPresentedNotification object:nil queue:[NSOperationQueue mainQueue]
			            usingBlock: ^(NSNotification *note) {
                            _presented = YES;
                        }];
			[nc addObserverForName:ASUserNotificationActivatedWithTypeNotification object:nil queue:[NSOperationQueue mainQueue]
			            usingBlock: ^(NSNotification *note) {
                            _activationType = [[note object] integerValue];
                        }];
		}
	}
	return _ASUserNotificationInstance;
}

- (instancetype)copyWithZone:(NSZone *)zone {
	ASUserNotification *copy = [super copy];
	[copy setTitle:self.title];
	[copy setSubtitle:self.subtitle];
	[copy setInformativeText:self.informativeText];
	[copy setHasActionButton:self.hasActionButton];
	[copy setActionButtonTitle:self.actionButtonTitle];
	[copy setOtherButtonTitle:self.otherButtonTitle];
	[copy setSoundName:self.soundName];
	[copy setUserInfo:self.userInfo];
	return copy;
}

- (ASUserNotificationFeature *)feature {
	return _feature;
}

- (void)setFeature:(ASUserNotificationFeature *)theFeature {
	if (![_feature isEqual:theFeature]) {
		_feature = nil;
		_feature = theFeature;
	}
}

@end



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSUserNotification+ASUserNotificationAdditions

const char kCNUserNotificationFeature;

@implementation NSUserNotification (ASUserNotificationAdditions)
- (id)init {
	self = [super init];
	if (self) [self setFeature:[ASUserNotificationFeature new]];
	return self;
}

- (ASUserNotificationFeature *)feature {
	return objc_getAssociatedObject(self, &kCNUserNotificationFeature);
}

- (void)setFeature:(ASUserNotificationFeature *)theFeature {
	objc_setAssociatedObject(self, &kCNUserNotificationFeature, theFeature, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
