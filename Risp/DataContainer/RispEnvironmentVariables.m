//
//  RispEnvironmentVariables.c
//  Risp
//
//  Created by closure on 3/13/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

// environment variable definition
NSString * const RispEnvCurrentFrameworkDirectory = @"*risp-framework-directory*";
NSString * const RispEnvCurrentWorkDirectory = @"*risp-work-directory*";
NSString * const RispEnvWorkDirectory = @"*risp-work-directory*";
NSString * const RispEnvIn = @"*in*";
NSString * const RispEnvOut = @"*out*";
NSString * const RispEnvError = @"*error*";

#import <Risp/RispRuntime.h>

FOUNDATION_EXPORT void RispEnvironmentVariablesInitialize() {
    NSBundle *rispFramework = [NSBundle bundleWithIdentifier:@"com.retval.Risp"];
    RispRuntime *rt = [RispRuntime baseEnvironment];
    [rt registerSymbol:[RispSymbol named:RispEnvCurrentFrameworkDirectory] forObject:[rispFramework bundlePath]];
    NSString *workDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
    [rt registerSymbol:[RispSymbol named:RispEnvCurrentWorkDirectory] forObject:workDirectory];
    
    NSFileHandle *handle = [[NSFileHandle alloc] initWithFileDescriptor:STDIN_FILENO closeOnDealloc:NO];
    [rt registerSymbol:[RispSymbol named:RispEnvIn] forObject:handle];
    handle = [[NSFileHandle alloc] initWithFileDescriptor:STDOUT_FILENO closeOnDealloc:NO];
    [rt registerSymbol:[RispSymbol named:RispEnvOut] forObject:handle];
    handle = [[NSFileHandle alloc] initWithFileDescriptor:STDERR_FILENO closeOnDealloc:NO];
    [rt registerSymbol:[RispSymbol named:RispEnvError] forObject:handle];
}
