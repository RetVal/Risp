//
//  RispStringReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispStringReader.h>
#import <Risp/RispPushBackReader.h>
#import <Risp/RispRuntime.h>
#import <Risp/RispReader.h>

@implementation RispStringReader
- (id)invoke:(RispReader *)reader object:(id)object {
    NSMutableString *sb = [[NSMutableString alloc] init];
    for (UniChar ch = [[reader reader] read1]; ch != '"'; ch = [[reader reader] read1]) {
        if (ch == 0) {
            [NSException raise:RispRuntimeException format:@"EOF while reading"];
        }
        if (ch == '\\') {
            ch = [[reader reader] read1];
            if (ch == 0) {
                [NSException raise:RispRuntimeException format:@"EOF while reading"];
            }
            switch (ch) {
                case 't':
                    ch = '\t';
                    break;
                case 'r':
                    ch = '\r';
                    break;
                case 'n':
                    ch = '\n';
                    break;
                case '\\':
                    break;
                case '"':
                    break;
                case 'b':
                    ch = '\b';
                    break;
                case 'f':
                    ch = '\f';
                    break;
                case 'u':
                    ch = [[reader reader] read1];
                    if (![RispBaseReader isDigit:ch decimal:16])
                        [NSException raise:RispRuntimeException format:@"Invalid unicode escape: \\u%C", ch];
                    ch = [RispBaseReader readUnicodeChar:[reader reader] ch:ch decimal:16 length:4 exact:YES];
                default:
                    if ([RispBaseReader isDigit:ch]) {
                        ch = [RispBaseReader readUnicodeChar:[reader reader] ch:ch decimal:8 length:3 exact:NO];
                        if (ch > 0377) {
                            [NSException raise:RispRuntimeException format:@"Octal escape sequence must be in range [0, 377]"];
                        }
                    } else {
                        [NSException raise:RispRuntimeException format:@"Unsupported escape character: \\%C", ch];
                    }
                    break;
            }
        }
        [sb appendFormat:@"%C", ch];
    }
    return sb;
}
@end
