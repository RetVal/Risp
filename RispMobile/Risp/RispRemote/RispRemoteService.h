//
//  RispRemoteService.h
//  Risp
//
//  Created by closure on 7/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/Risp.h>

@class RispRemoteService;

@protocol RispRemoteServiceDelegate <NSObject>

@required
- (void)remoteService:(RispRemoteService *)service didReceiveContent:(id)content;

@optional
- (void)remoteServiceDidOpen:(RispRemoteService *)service;
- (void)remoteService:(RispRemoteService *)service didFailWithError:(NSError *)error;
- (void)remoteService:(RispRemoteService *)service didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
@end

@interface RispRemoteService : NSObject
@property (nonatomic, weak) id<RispRemoteServiceDelegate> delegate;

+ (instancetype)defaultService;
- (instancetype)init;
- (void)reconnect;
- (BOOL)ready;
- (void)send:(id)message;
@end
