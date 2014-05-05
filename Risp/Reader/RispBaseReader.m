//
//  RispBaseReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispBaseReader.h>
#import <Risp/RispPushBackReader.h>
#import <Risp/RispRuntime.h>
#import <Risp/RispReader.h>

NSMutableArray *RispMacros = nil;
NSMutableArray *RispDispatchMacros = nil;

static RispBaseReader *reader = nil;
@interface RispBaseReader() {
    NSString *_content;
}
@end

@implementation RispBaseReader
+ (void)load {
    RispMacros = [[NSMutableArray alloc] initWithCapacity:256];
    RispDispatchMacros = [[NSMutableArray alloc] initWithCapacity:256];
    reader = [[RispBaseReader alloc] init];
    for (NSUInteger idx = 0; idx < 256; idx++) {
        RispMacros[idx] = @"";
        RispDispatchMacros[idx] = @"";
    }
}

+ (BOOL)isWhiteSpace:(NSInteger)ch {
    return ch == ',' || [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:ch];
}

+ (BOOL)isDigit:(NSInteger)ch {
    return isdigit((unichar)ch);
}

+ (BOOL)isDigit:(NSInteger)ch decimal:(NSInteger)decimal {
    return isdigit((unichar)ch) || decimal == 16 ? ishexnumber((unichar)ch) : NO;
}

+ (BOOL)isTerminatingMacro:(NSInteger)ch {
    return (ch != '#' && ch != '\'' && ch != '%' && [self isMacros:ch]);
}

+ (BOOL)isMacros:(NSInteger)ch {
    if (ch < 256) {
        id m = [RispBaseReader macro:ch];
        if (m && ![m isEqualTo:@""]) {
            return YES;
        }
    }
    return NO;
}

+ (id)macro:(NSInteger)ch {
    if (ch < [RispMacros count]) {
        return RispMacros[ch];
    }
    return nil;
}

+ (NSInteger)readUnicodeChar:(RispPushBackReader *)reader ch:(NSInteger)ch decimal:(NSInteger)base length:(NSUInteger)length exact:(BOOL)exact {
    NSInteger uc = isdigit((unichar)ch) || base == 16 ? [[NSCharacterSet alphanumericCharacterSet] characterIsMember:ch] : NO;
    NSUInteger i = 1;
    for (; i < length; i++) {
        UniChar ch = [reader read1];
        if (ch == 0 || [RispBaseReader isWhiteSpace:ch] || [RispBaseReader isMacros:ch]) {
            [reader unread:ch];
            break;
        }
        NSInteger d = isdigit((unichar)ch) || base == 16 ? [[NSCharacterSet alphanumericCharacterSet] characterIsMember:ch] : NO;
        if (d == -1)
            [NSException raise:RispInvalidNumberFormatException format:@"Invalid digit: %C", ch];
        uc = uc * base + d;
    }
    if (i != length && exact)
        [NSException raise:RispIllegalArgumentException format:@"Invalid character length: %ld, should be: %ld", i, length];
    return uc;
}


- (id)initWithContent:(NSString *)content {
    if (self = [super init]) {
        _content = content;
    }
    return self;
}

- (id)initWithContentOfFile:(NSString *)path {
    return [self initWithData:[NSData dataWithContentsOfFile:path]];
}

- (id)initWithData:(NSData *)data {
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!content)
        return nil;
    return [self initWithContent:content];
}

- (id)invoke:(RispReader *)reader object:(id)object {
    return nil;
}

- (id <RispSequence>)reader:(RispReader *)reader delimited:(unichar)delimit recursive:(BOOL)isRecursive {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (; ;) {
        unichar ch = [[reader reader] read1];
        while ([RispBaseReader isWhiteSpace:ch]) {
            ch = [[reader reader] read1];
        }
        if (ch == 0) {
            [NSException raise:RispRuntimeException format:@"EOF while reading"];
        }
        
        if (ch == delimit) {
            break;
        }
        
        id macroFn = [RispBaseReader macro:ch];
        if (macroFn && ![macroFn isEqual: @""]) {
            id mret = [macroFn invoke:reader object:@(ch)];
            if (mret != reader) {
                [array addObject:mret];
            }
        } else {
            [[reader reader] unread:ch];
            id o = [reader readEofIsError:YES eofValue:nil isRecursive:isRecursive];
            if (o != reader) {
                [array addObject:o];
            }
        }
    }
    return [RispList listWithObjectsFromArray:array];
}
@end
