//
//  TodayViewController.m
//  RispNotificationExtension
//
//  Created by closure on 10/22/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispTodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <Risp/Risp.h>
#import <RispRemote/RispRemoteService.h>
#import <RispRemote/RispEvalCore.h>

@interface RispTodayViewController () <NCWidgetProviding, RispRemoteServiceDelegate>
@property (nonatomic, strong) RispRemoteService *remoteService;
@property (nonatomic, strong, readonly) NSMutableArray *messages;
@end

@implementation RispTodayViewController

- (void)remoteService:(RispRemoteService *)service didReceiveContent:(id)content {
    if ([content isKindOfClass:[NSString class]]) {
        NSDictionary *expressions = nil;
        NSArray *results = [RispEvalCore evalCurrentLine:content evalResult:&expressions];
        
        @autoreleasepool {
            [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSMutableString *desc = [[NSMutableString alloc] init];
                NSDictionary *info = expressions[obj];
                if (info[RispExceptionKey]) {
                    NSException *exception = info[RispExceptionKey];
                    [desc appendFormat:@"%@ -> %@", obj, exception];
                    [[RispRemoteService defaultService] send:[NSString stringWithFormat:@"%@ -> %@", obj, [exception callStackSymbols]]];
                } else {
                    [desc appendFormat:@"%@ -> %@\n", obj, info[RispEvalValueKey]];
                }
                
                NSLog(@"%@", desc);
                [_remoteService send:desc];
            }];
        }
        NSLog(@"%@ -> done", content);
        [_codeLabel setText:[NSString stringWithFormat:@"%@ -> %@", [results lastObject], expressions[[results lastObject]][RispEvalValueKey]]];
        
    } else if ([content isKindOfClass:[NSData class]]) {
        assert(NO);
    } else {
        assert(NO);
    }
}

- (void)remoteServiceDidOpen:(RispRemoteService *)service {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Connected");
        [_codeLabel setText:@"Connected"];
    }); 
}

- (void)remoteService:(RispRemoteService *)service didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Closed");
        [_codeLabel setText:@"Closed"];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Reconnecting");
        [_codeLabel setText:@"Reconnecting"];
        [_remoteService reconnect];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _remoteService = [RispRemoteService defaultService];
    [_remoteService setDelegate:self];
    [_remoteService reconnect];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    NCUpdateResult result = [_messages count] ? NCUpdateResultNewData : NCUpdateResultNoData;
    NSLog(@"!");
    if (![_remoteService ready]) {
        [_remoteService reconnect];
        result = NCUpdateResultFailed;
        completionHandler(result);
        return;
    }
    [_codeLabel setText:[_messages description]];
    NSLog(@"done");
    [_messages removeAllObjects];
    completionHandler(result);
}

@end
