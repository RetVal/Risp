//
//  RispCompilerExceptionManager.h
//  RispCompiler
//
//  Created by closure on 8/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RispCompilerExceptionLocation;
@interface RispCompilerExceptionManager : NSObject
+ (instancetype)defaultManager;
- (void)addExceptionLocation:(RispCompilerExceptionLocation *)exceptionLocation;
@end
