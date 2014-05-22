//
//  RispUnquoteReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispUnquoteReader.h"

@implementation RispUnquoteReader
- (id)invoke:(RispReader *)reader object:(id)object {
    RispPushBackReader *pushBackReader = [reader reader];
    UniChar ch = [pushBackReader read1];
    if (ch == 0) {
        [NSException raise:RispRuntimeException format:@"EOF while reading character"];
    }
    if (ch == '@') {
        id o = [reader readEofIsError:YES eofValue:nil isRecursive:YES];
        return [[RispList alloc] initWithObject:[RispSymbol UNQUOTESPLICING] base:[RispSequence sequence:o]];
    }
    [pushBackReader unread:ch];
    id o = [reader readEofIsError:YES eofValue:nil isRecursive:YES];
    return [[RispList alloc] initWithObject:[RispSymbol UNQUOTE] base:[RispSequence sequence:o]];
}
@end
