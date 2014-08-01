//
//  RispRemoteServer.m
//  Risp
//
//  Created by closure on 7/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispRemoteServer.h"

#import <CoreWebSocket/CoreWebSocket.h>
#include <dispatch/dispatch.h>

void didAddClientCallback(WebSocketRef webSocket, WebSocketClientRef client) {
    WebSocketClientWriteWithString(client, CFSTR("(+ 1 2)"));
}


void didClientReadCallback(WebSocketRef self, WebSocketClientRef client, CFStringRef value) {
    if (value) {
        WebSocketClientWriteWithFormat(client, CFSTR("(+ 1 2)"));
    }
}

void willRemoveClientCallback(WebSocketRef webSocket, WebSocketClientRef client) {
    NSLog(@"client will be removed");
}

static int weak() {
    @autoreleasepool {
        WebSocketRef webSocket = WebSocketCreateWithHostAndPort(nil, kWebSocketHostAny, 9000, nil);
        if (webSocket) {
            NSLog(@"Running on %@:9000....", kWebSocketHostAny);
            WebSocketSetClientReadCallback(webSocket, didClientReadCallback);
            WebSocketSetAddClientCallback(webSocket, didAddClientCallback);
            WebSocketSetWillRemoveClientCallback(webSocket, willRemoveClientCallback);
            CFRunLoopRun();
            WebSocketRelease(webSocket);
        }
    }
    return 0;
}


@implementation RispRemoteServer
+ (void)load {
    
}
@end
