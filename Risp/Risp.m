//
//  Risp.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>
#import "Risp+DEBUG.h"

@implementation Risp

+ (void)load {
    [RispContext setCurrentContext:[RispContext defaultContext]];
    RispReader *reader = [[RispReader alloc] initWithContentOfFile:[@"/SourceCache/Risp/init.risp" stringByStandardizingPath]];
    while (![reader isEnd]) {
        @autoreleasepool {
            @try {
                id value = [reader readEofIsError:YES eofValue:nil isRecursive:YES];
                [[reader reader] skip];
                if (value == reader) {
                    continue;
                }
                RispContext *context = [RispContext currentContext];
                id expression = [RispCompiler compile:context form:value];
                id v = [expression eval];
                NSLog(@"%@ -> %@", value, v);
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            @finally {
                
            }
        }
    }
}

@end