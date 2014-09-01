//
//  RispCompilerExceptionManager.m
//  RispCompiler
//
//  Created by closure on 8/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <RispCompiler/RispCompilerExceptionManager.h>
#import <RispCompiler/RispCompilerExceptionLocation.h>
#include <libkern/OSAtomic.h>

@interface RispCompilerExceptionManager () {
    @private
    OSSpinLock _exceptionLocationLock;
}
@property (nonatomic, strong, readonly) NSMutableArray *exceptionLocation;
@end

@implementation RispCompilerExceptionManager
+ (instancetype)defaultManager {
    static RispCompilerExceptionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RispCompilerExceptionManager alloc] init];
    });
    return manager;
}

- (void)addExceptionLocation:(RispCompilerExceptionLocation *)exceptionLocation {
    OSSpinLockLock(&_exceptionLocationLock);
    [_exceptionLocation addObject:exceptionLocation];
    OSSpinLockUnlock(&_exceptionLocationLock);
}
@end
