//
//  RispNumberReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispNumberReader.h>
#import <Risp/RispPushBackReader.h>
#import <Risp/RispRuntime.h>
#import <Risp/RispReader.h>

@implementation RispNumberReader

+ (id)matchNumber:(NSString *)s {
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSDecimalNumber *num = [[NSDecimalNumber alloc] initWithString:s];
    return num;
}

- (id)invoke:(RispReader *)reader object:(id)object {
    unichar initch = [[reader reader] read1];
    NSMutableString *sb = [[NSMutableString alloc] init];
    [sb appendFormat:@"%C", initch];
    for (; ;) {
        NSInteger ch = [[reader reader] read1];
        if (ch == 0 || [RispBaseReader isWhiteSpace:ch] || [RispBaseReader isMacros:ch]) {
            [[reader reader] unread:ch];
            break;
        }
        [sb appendFormat:@"%C", (unichar)ch];
    }
    id n = [RispNumberReader matchNumber:sb];
    if (n == nil) {
        [NSException raise:RispInvalidNumberFormatException format:@"invalid number format: %@", sb];
    }
    return n;
}
@end
