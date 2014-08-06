//
//  RispArgumentsReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispArgumentsReader.h>
#import <Risp/RispVector.h>
#import <Risp/RispList.h>
#import <Risp/RispReader.h>
#import <Risp/RispTokenReader.h>
#import <Risp/RispRuntime.h>

@implementation RispArgumentsReader
- (RispSymbol *)registerArguments:(NSInteger)n {
    RispSymbol *symbol = nil;
    if (n == 1) {
        symbol = [RispSymbol named:@"%"];
    } else {
        symbol = [RispSymbol named:[NSString stringWithFormat:@"%%%ld", n]];
    }
    [[[RispContext currentContext] currentScope] setObject:symbol forKey:symbol];
    return symbol;
}

- (id)invoke:(RispReader *)reader object:(id)object {
    RispPushBackReader *r = [reader reader];
    unichar ch = [r read1];
    [r unread:ch];
    if (ch == 0 || [RispBaseReader isWhiteSpace:ch] || [RispBaseReader isTerminatingMacro:ch]) {
        return [self registerArguments:1];
    }
    id n = [reader readEofIsError:YES eofValue:nil isRecursive:YES];
    if (n == reader) {
        return reader;
    }
    if ([n isEqualTo:@0]) {
        return [self registerArguments:-1];
    }
    if (![n isKindOfClass:[NSNumber class]]) {
        [NSException raise:RispIllegalArgumentException format:@"arg literal must be %%, %%& or %%integer"];
    }
    return [self registerArguments:[n intValue]];
}
@end
