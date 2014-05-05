//
//  RispCommentReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispCommentReader.h>
#import <Risp/RispPushBackReader.h>
#import <Risp/RispReader.h>

@implementation RispCommentReader
- (id)invoke:(RispReader *)reader object:(id)object {
    NSInteger ch = 0;
    do {
        ch = [[reader reader] read1];
    } while (ch != 0 && ch != '\n' && ch != '\r');
    return reader;
}
@end
