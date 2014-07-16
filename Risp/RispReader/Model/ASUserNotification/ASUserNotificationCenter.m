//
//  ASUserNotificationCenter.m
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

#import "ASUserNotificationBannerController.h"


NSString *const ASUserNotificationDismissDelayTimeKey = @"ASUserNotificationDismissDelayTimeKey";
NSString *const ASUserNotificationBannerArchivedImageKey = @"ASUserNotificationBannerArchivedImageKey";
NSString *const ASUserNotificationBannerLineBreakModeKey = @"ASUserNotificationBannerLineBreakModeKey";

NSString *const ASUserNotificationDismissBannerNotification = @"ASUserNotificationDismissBannerNotification";
NSString *const ASUserNotificationActivatedWithTypeNotification = @"ASUserNotificationActivatedWithTypeNotification";

NSString *const ASUserNotificationDefaultSound = @"ASUserNotificationDefaultSound";
NSString *const NSUserNotificationDefaultSoundName = @"NSUserNotificationDefaultSoundName";


@interface ASUserNotificationCenter () {}
@property (strong) ASUserNotificationBannerController *notificationBannerController;
@property (strong) NSMutableArray *deliveredNotifications;
@property (strong, nonatomic) NSMutableArray *cn_scheduledNotifications;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wswitch"
@implementation ASUserNotificationCenter

+ (instancetype)defaultUserNotificationCenter {
	__strong static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    if (NSClassFromString(@"NSUserNotificationCenter")) sharedInstance = [NSUserNotificationCenter defaultUserNotificationCenter];
	    else sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
}

+ (instancetype)customUserNotificationCenter {
	__strong static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{ sharedInstance = [[[self class] alloc] init]; });
	return sharedInstance;
}

- (id)init {
	self = [super init];
	if (self) {
		_notificationBannerController = nil;
		_cn_scheduledNotifications = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)deliverNotification:(ASUserNotification *)notification {
	ASUserNotificationBannerActivationHandler activationHandler = ^(ASUserNotificationActivationType activationType) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ASUserNotificationActivatedWithTypeNotification object:@(activationType)];
		switch (activationType) {
			case ASUserNotificationActivationTypeContentsClicked:
			case ASUserNotificationActivationTypeActionButtonClicked: {
				ASUserNotificationCenter *center = [ASUserNotificationCenter defaultUserNotificationCenter];
				if ([self userNotificationCenter:center shouldPresentNotification:notification]) {
					[self userNotificationCenter:center didActivateNotification:notification];
				}
				break;
			}
		}
	};

	self.notificationBannerController = nil;
	self.notificationBannerController = [[ASUserNotificationBannerController alloc] initWithNotification:notification
	                                                                                            delegate:self.delegate
	                                                                              usingActivationHandler:activationHandler];
	// inform the delegate
	[self userNotificationCenter:self didDeliverNotification:notification];

	[self.notificationBannerController presentBannerDismissAfter:notification.feature.dismissDelayTime];

	if (notification.soundName != nil) {
		if ([notification.soundName isEqualToString:ASUserNotificationDefaultSound]) {
			[[NSSound soundNamed:ASUserNotificationDefaultSound] play];
		}
		else {
			[[NSSound soundNamed:notification.soundName] play];
		}
	}
}

#pragma mark - ASUserNotificationCenter Delegate

- (void)userNotificationCenter:(ASUserNotificationCenter *)center didDeliverNotification:(ASUserNotification *)notification {
	if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate userNotificationCenter:center didDeliverNotification:notification];
	}
}

- (BOOL)userNotificationCenter:(ASUserNotificationCenter *)center shouldPresentNotification:(ASUserNotification *)notification {
	BOOL shouldPresent = NO;
	if ([self.delegate respondsToSelector:_cmd]) {
		shouldPresent = [self.delegate userNotificationCenter:center shouldPresentNotification:notification];
	}
	return shouldPresent;
}

- (void)userNotificationCenter:(ASUserNotificationCenter *)center didActivateNotification:(ASUserNotification *)notification {
	if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate userNotificationCenter:center didActivateNotification:notification];
		[[NSNotificationCenter defaultCenter] postNotificationName:ASUserNotificationDismissBannerNotification object:nil];
	}
}

@end
#pragma clang diagnostic pop
