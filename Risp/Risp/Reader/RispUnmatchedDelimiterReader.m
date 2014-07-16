//
//  RispUnmatchedDelimiterReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispUnmatchedDelimiterReader.h"
#import <Risp/RispRuntime.h>

static RispUnmatchedDelimiterReader *__RispUnmatchedDelimiterReader = nil;
@implementation RispUnmatchedDelimiterReader
- (id)init {
    static dispatch_once_t onceToken;
    if (__RispUnmatchedDelimiterReader)
        return __RispUnmatchedDelimiterReader;
    
    if (self = [super init]) {
        dispatch_once(&onceToken, ^{
            __RispUnmatchedDelimiterReader = self;
        });
    }
    return __RispUnmatchedDelimiterReader;
}

- (id)invoke:(RispReader *)reader object:(id)object {
    [NSException raise:RispRuntimeException format:@"Unmatched delimiter: %C", (UniChar)[object unsignedIntegerValue]];
    return nil;
}
@end
