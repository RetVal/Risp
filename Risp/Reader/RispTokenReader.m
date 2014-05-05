//
//  RispTokenReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispTokenReader.h>
#import <Risp/RispPushBackReader.h>
#import <Risp/RispReader.h>
#import <Risp/RispToken.h>

@implementation RispTokenReader
- (id)invoke:(RispReader *)reader object:(id)object {
    UniChar initch = [[reader reader] read1];
    NSMutableString *sb = [[NSMutableString alloc] init];
    [sb appendFormat:@"%C", initch];
    for (; ;) {
        UniChar ch = [[reader reader] read1];
        if (ch == 0 || [RispBaseReader isWhiteSpace:ch] || [RispBaseReader isTerminatingMacro:ch]) {
            [[reader reader] unread:ch];
            return sb;
        }
        [sb appendFormat:@"%C", ch];
    }
    return nil;
}
@end
