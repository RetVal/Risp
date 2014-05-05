//
//  Risp.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>

@interface Risp : NSObject

@end

@implementation Risp

+ (void)load {
    [RispContext setCurrentContext:[RispContext defaultContext]];
    RispReader *reader = [[RispReader alloc] initWithContentOfFile:[@"/SourceCache/Risp/init.risp" stringByStandardizingPath]];
    while (![reader isEnd]) {
        id value = [reader readEofIsError:YES eofValue:nil isRecursive:YES];
        NSLog(@"value -> %@", value);
        [[reader reader] skip];
        RispContext *context = [RispContext currentContext];
        id v = [RispCompiler compile:context form:value];
        v = [v eval];
        NSLog(@"%@", v);
    }
}

@end