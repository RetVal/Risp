//
//  __RispReaderRemoteService.h
//  Risp
//
//  Created by closure on 7/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/Risp.h>

@class __RispReaderRemoteService;

@protocol __RispReaderRemoteServiceDelegate <NSObject>

@required
- (void)remoteService:(__RispReaderRemoteService *)service didReceiveContent:(id)content;

@optional
- (void)remoteServiceDidOpen:(__RispReaderRemoteService *)service;
- (void)remoteService:(__RispReaderRemoteService *)service didFailWithError:(NSError *)error;
- (void)remoteService:(__RispReaderRemoteService *)service didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
@end

@interface __RispReaderRemoteService : NSObject 
@property (nonatomic, weak) id<__RispReaderRemoteServiceDelegate> delegate;

+ (instancetype)defaultService;
- (instancetype)init;
- (void)reconnect;
- (BOOL)ready;
- (void)send:(id)message;
@end
