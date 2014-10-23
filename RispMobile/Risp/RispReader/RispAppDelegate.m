//
//  AppDelegate.m
//  RispReader
//
//  Created by closure on 7/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispAppDelegate.h"
//#import <MediaPlayer/MediaPlayer.h>
#import <RispRemote/RispRemoteService.h>
#import <RispRemote/RispEvalCore.h>

@interface _RispRemoteServiceDelegate : NSObject <RispRemoteServiceDelegate> {
    @private
    
}
- (void)remoteService:(RispRemoteService *)service didReceiveContent:(id)content;
@end

@implementation _RispRemoteServiceDelegate

- (void)remoteService:(RispRemoteService *)service didReceiveContent:(id)content {
    if (![content isKindOfClass:[NSString class]]) {
        NSLog(@"%@", content);
        return;
    }
}

@end

@interface RispAppDelegate () {
    @private
    UIBackgroundTaskIdentifier _backgroundTaskIdentifier;
}

@end

@implementation RispAppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
//    [[MPMusicPlayerController systemMusicPlayer] setVolume:0];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    _backgroundTaskIdentifier = [application beginBackgroundTaskWithName:@"RispCode" expirationHandler:^{
        RispRemoteService *remoteService = [RispRemoteService defaultService];
        [remoteService send:@"entry background"];
        [application endBackgroundTask:_backgroundTaskIdentifier];
        _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    RispRemoteService *remoteService = [RispRemoteService defaultService];
    if (![remoteService ready]) {
        [remoteService reconnect];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
