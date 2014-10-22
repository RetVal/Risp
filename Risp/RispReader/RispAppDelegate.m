//
//  RispAppDelegate.m
//  RispReader
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispAppDelegate.h"
#import <Risp/RispSymbol.h>
#import <Risp/RispAbstractSyntaxTree.h>

#import "RispRenderWindowController.h"
#import "RispREPLAlphaWindowController.h"
#import "RispHUDWindowController.h"
#import "RispReaderEvalCore.h"

#import "RispRender.h"
#include <pthread.h>

#import "ASUserNotification.h"

#import <WebKit/WebKit.h>

@interface RispAppDelegate ()
@property (nonatomic, strong) RispRenderWindowController *rootWindowController;
@property (nonatomic, strong) RispREPLAlphaWindowController *replWindowController;
@property (nonatomic, strong) RispHUDWindowController *hudWindowController;
@end

@implementation RispAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _hudWindowController = [[RispHUDWindowController alloc] initWithWindowNibName:@"RispHUDWindowController"];
    [[_hudWindowController window] makeKeyAndOrderFront:self];
    _replWindowController = [[RispREPLAlphaWindowController alloc] initWithWindowNibName:@"RispREPLAlphaWindowController"];
    [[_replWindowController window] makeKeyAndOrderFront:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return NO;
}

- (IBAction)evalCurrentLine:(id)sender {
    [_hudWindowController setValue:nil];
    NSArray *expressions = nil;
    NSArray *values = [RispReaderEvalCore evalCurrentLine:[[_replWindowController inputTextView] string] expressions:&expressions];
    
    [expressions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_hudWindowController setValue:[[[RispAbstractSyntaxTree alloc] initWithExpression:obj] description]];
    }];
    
    [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSNull class]]) return ;
        NSString *prefix = [[NSString alloc] initWithFormat:@"%@ %@ [%d:%d] ", [[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S.%F"], [[NSProcessInfo processInfo] processName], getpid(), pthread_mach_thread_np(pthread_self())];
        NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:prefix];
        [mas appendAttributedString:[obj render]];
        [mas appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [[[_replWindowController outputTextView] textStorage] appendAttributedString:mas];
    }];
}

#pragma mark - ASUserNotification Delegate

- (BOOL)userNotificationCenter:(ASUserNotificationCenter *)center shouldPresentNotification:(ASUserNotification *)notification {
	return YES;
}

- (void)userNotificationCenter:(ASUserNotificationCenter *)center didActivateNotification:(ASUserNotification *)notification {
    //    NSLog(@"userNotificationCenter:didActivateNotification: %@", notification);
	NSString *urlToOpen = [notification.userInfo objectForKey:@"openThisURLBecauseItsAwesome"];
	if (urlToOpen && ![urlToOpen isEqualToString:@""]) {
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlToOpen]];
	}
}

- (void)userNotificationCenter:(ASUserNotificationCenter *)center didDeliverNotification:(ASUserNotification *)notification {
    //    NSLog(@"userNotificationCenter:didDeliverNotification: %@", notification);
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (flag == NO) {
        [[_hudWindowController window] makeKeyAndOrderFront:self];
        [[_replWindowController window] makeKeyAndOrderFront:self];
    }
    return NO;
}

#pragma mark - Background Working

- (void)applicationWillBecomeActive:(NSNotification *)notification {
    
}
@end
