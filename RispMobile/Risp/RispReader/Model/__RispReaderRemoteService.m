//
//  __RispReaderRemoteService.m
//  Risp
//
//  Created by closure on 7/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "__RispReaderRemoteService.h"
#import "RispEvalCore.h"
#import <RispSocketRocket/RispSocketRocket.h>

@interface __RispReaderRemoteService () <SRWebSocketDelegate>
@property (strong, nonatomic, readonly) SRWebSocket *connection;
@end

@implementation __RispReaderRemoteService
+ (void)load {
    [__RispReaderRemoteService defaultService];
}

+ (instancetype)defaultService {
    static dispatch_once_t onceToken;
    static __RispReaderRemoteService *service = nil;
    dispatch_once(&onceToken, ^{
        service = [[__RispReaderRemoteService alloc] init];
    });
    return service;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)_reconnect {
    [_connection setDelegate:nil];
    [_connection close];
    _connection = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://localhost:9000/chat"]];
    [_connection setDelegate:self];
    [_connection open];
}

- (void)reconnect {
    [self _reconnect];
}

- (void)send:(id)message {
    return [_connection send:message];
}

#pragma mark -
#pragma mark SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([message isKindOfClass:[NSString class]]) {
        NSLog(@"message -> %@", message);
    } else if ([message isKindOfClass:[NSData class]]) {
        NSLog(@"message -> %@", message);
    }
    if (_delegate) {
        [_delegate remoteService:self didReceiveContent:message];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"connected to the server");
    if (_delegate) {
        [_delegate remoteServiceDidOpen:self];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"error -> %@", error);
    if (_delegate) {
        [_delegate remoteService:self didFailWithError:error];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"close code -> %ld, reason -> %@", code, reason);
    if (_delegate) {
        [_delegate remoteService:self didCloseWithCode:code reason:reason wasClean:wasClean];
    }
}
@end
