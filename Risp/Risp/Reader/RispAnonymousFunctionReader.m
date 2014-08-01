//
//  RispAnonymousFunctionReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispAnonymousFunctionReader.h>
#import <Risp/RispContext.h>
#import <Risp/RispReader.h>
#import <Risp/RispSymbol+BIF.h>

@implementation RispAnonymousFunctionReader
- (id)invoke:(RispReader *)reader object:(id)object {
    id <RispSequence>seq = nil;
    @try {
        RispContext *context = [RispContext currentContext];
        [context pushScope];
        [[reader reader] unread:'('];
        id form = [reader readEofIsError:YES eofValue:nil isRecursive:YES];
        NSArray *args = [[[context currentScope] keys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 stringValue] compare:[obj2 stringValue] options:NSNumericSearch];
        }];
        seq = [RispList listWithObjectsFromArray:@[[RispSymbol FN], [RispVector listWithObjectsFromArrayNoCopy:args], form]];
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        [[RispContext currentContext] popScope];
    }
    return seq;
}
@end
