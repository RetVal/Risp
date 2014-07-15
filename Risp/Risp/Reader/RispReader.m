//
//  RispReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispReader.h>
#import <Risp/RispPushBackReader.h>
#import <Risp/RispRuntime.h>
#import <Risp/RispToken.h>
#import <Risp/RispKeyword.h>

#import <RispBaseReader.h>
#import <Risp/RispStringReader.h>
#import <Risp/RispNumberReader.h>
#import <Risp/RispTokenReader.h>
#import <Risp/RispCommentReader.h>
#import <Risp/RispWrappingReader.h>
#import <Risp/RispSyntaxQuoteReader.h>
#import <Risp/RispUnquoteReader.h>
#import <Risp/RispUnmatchedDelimiterReader.h>
#import <Risp/RispVectorReader.h>
#import <Risp/RispMapReader.h>
#import <Risp/RispDispatchReader.h>

static RispTokenReader *__RispTokenReader = nil;
static RispNumberReader *__RispNumberReader = nil;
@interface RispReader()
@property (strong, nonatomic, readonly) RispLexicalScope *scope;
@end
@implementation RispReader
+ (void)load {
    __RispTokenReader = [[RispTokenReader alloc] init];
    __RispNumberReader = [[RispNumberReader alloc] init];
    
    // init macros
    RispMacros['"'] = [[RispStringReader alloc] init];
    RispMacros[';'] = [[RispCommentReader alloc] init];
    RispMacros['\''] = [[RispWrappingReader alloc] initWithSymbol:[RispSymbol QUOTE]];
    RispMacros['@'] = [[RispWrappingReader alloc] initWithSymbol:[RispSymbol named:@"deref"]];
    RispMacros['`'] = [[RispSyntaxQuoteReader alloc] init];
    RispMacros['~'] = [[RispUnquoteReader alloc] init];
    RispMacros['('] = [[RispListReader alloc] init];
    RispMacros[')'] = [[RispUnmatchedDelimiterReader alloc] init];
    RispMacros['['] = [[RispVectorReader alloc] init];
    RispMacros[']'] = [[RispUnmatchedDelimiterReader alloc] init];
    RispMacros['{'] = [[RispMapReader alloc] init];
    RispMacros['}'] = [[RispUnmatchedDelimiterReader alloc] init];
    RispMacros['%'] = [[RispArgumentsReader alloc] init];
    RispMacros['#'] = [[RispDispatchReader alloc] init];
    
    RispDispatchMacros['"'] = [[RispRegexReader alloc] init];
    RispDispatchMacros['('] = [[RispAnonymousFunctionReader alloc] init];
    RispDispatchMacros[')'] = [[RispUnmatchedDelimiterReader alloc] init];
}

- (id)initWithContent:(NSString *)content fileNamed:(NSString *)file {
    if (!content)
        return nil;
    if (self = [super initWithContent:content fileNamed:file]) {
        _reader = [[RispPushBackReader alloc] initWithContent:content fileNamed:file];
        _scope = [[RispContext currentContext] currentScope];
    }
    return self;
}

- (id)setupDebugInformationForObject:(id)object start:(NSInteger)start columnNumber:(NSInteger)columnNumber lineNumber:(NSInteger)lineNumber {
    [object setStart:start];
    [object setEnd:[_reader pos]];
    [object setFile:[_reader file]];
    [object setColumnNumber:columnNumber];
    [object setLineNumber:lineNumber];
    return object;
}

- (id)readEofIsError:(BOOL)eofIsError eofValue:(id)eofValue isRecursive:(BOOL)recursive {
    @try {
        for (; ;) {
            NSInteger start = [_reader pos];
            NSInteger columnNumber = [_reader columnNumber];
            NSInteger lineNumber = [_reader lineNumber];
            
            UniChar ch = [_reader read1];
            while ([RispReader isWhiteSpace:ch])
                ch = [_reader read1];
            if (ch == 0) {
                if(eofIsError)
					@throw [NSException exceptionWithName:RispRuntimeException reason:@"EOF while reading" userInfo:nil];
				return eofValue;
            }
            if ([RispBaseReader isDigit:ch]) {
                [_reader unread:ch];
                id object = [__RispNumberReader invoke:self object:nil];
                return [self setupDebugInformationForObject:object start:start columnNumber:columnNumber lineNumber:lineNumber];
            }
            
            id macroFn = [RispBaseReader macro:ch];
            if (![macroFn  isEqual: @""] && macroFn != nil) {
                id ret = [macroFn invoke:self object:@(ch)];
                if (ret == self) {
                    return self;
                }
                return [self setupDebugInformationForObject:ret start:start columnNumber:columnNumber lineNumber:lineNumber];
            }
            
            if (ch == '+' || ch == '-') {
                NSInteger ch2 = [_reader read1];
                if ([RispBaseReader isDigit:ch2]) {
                    [_reader unread:ch2];
                    id n = [__RispNumberReader invoke:self object:nil];
                    if (ch == '-') {
                        n = [n decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInt:-1]];
                    }
                    return [self setupDebugInformationForObject:n start:start columnNumber:columnNumber lineNumber:lineNumber];
                }
                [_reader unread:ch2];
            }
            
            [_reader unread:ch];
            NSString *token = [__RispTokenReader invoke:self object:nil];
            id tk = [self interpretToken:token];
            return [self setupDebugInformationForObject:tk start:start columnNumber:columnNumber lineNumber:lineNumber];
        }
    }
    @catch (NSException *exception) {
        @throw exception;
    }
}

- (id)interpretToken:(NSString *)token {
    if ([token isEqualTo:@"nil"]) {
        return [NSNull null];
    } else if ([token isEqualTo:@"true"]) {
        return @YES;
    } else if ([token isEqualTo:@"false"]) {
        return @NO;
    } else if ([token isEqualTo:@"/"]) {
        return [RispSymbol named:@"/"];
    }
    if ([RispKeyword isKeyword:token]) {
        return [RispKeyword named:token];
    }
    id ret = [RispSymbol named:token];
    if (ret != nil)
        return ret;
    [NSException raise:RispRuntimeException format:@"Invalid token: %@", token];
    return nil;
}

- (id)invoke:(RispReader*)reader object:(id)object {
    return nil;
}

- (BOOL)isEnd {
    return !([_reader pos]  < [_reader length]);
}
@end
