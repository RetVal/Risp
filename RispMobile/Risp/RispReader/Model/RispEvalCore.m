//
//  RispEvalCore.m
//  Risp
//
//  Created by closure on 7/16/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispEvalCore.h"

NSString * RispExpressionKey = @"expression";
NSString * RispEvalValueKey = @"eval";
NSString * RispExceptionKey = @"exception";

@implementation RispEvalCore

+ (NSArray *)evalCurrentLine:(NSString *)sender evalResult:(NSDictionary **)dict {
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    RispContext *context = [RispContext currentContext];
    RispReader *reader = [[RispReader alloc] initWithContent:sender fileNamed:@"RispREPL"];
    id value = nil;
    NSMutableDictionary *infos = nil;
    if (dict) {
        infos = [[NSMutableDictionary alloc] init];
        *dict = infos;
    }
    while (![reader isEnd]) {
        @autoreleasepool {
            NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
            @try {
                value = [reader readEofIsError:YES eofValue:nil isRecursive:YES];
                [[reader reader] skip];
                if (value == reader) {
                    // comment
                    continue;
                }
                id expr = [RispCompiler compile:context form:value];
                
                if (expr) {
                    info[RispExpressionKey] = expr;
                }
                
                id v = [expr eval];
                info[RispEvalValueKey] = v ?: [NSNull null];
                
                if ([expr conformsToProtocol:@protocol(RispExpression)]) {
                    NSLog(@"%@ -\n%@\n-> %@", value, [[[RispAbstractSyntaxTree alloc] initWithExpression:expr] description], v);
                } else {
                    NSLog(@"%@ -\n%@\n-> %@", value, [RispAbstractSyntaxTree descriptionAppendIndentation:0 forObject:expr], v);
                }
            }
            @catch (NSException *exception) {
                info[RispExceptionKey] = exception;
                NSLog(@"%@ - %@\n%@", value, exception, [exception callStackSymbols]);
            }
            @finally {
                id key = [value description];
                if (!key) {
                    key = sender;
                }
                if (key && info) {
                    infos[key] = info;
                    [keys addObject:key];
                }
            }
        }
    }
    return keys;
}

+ (NSArray *)evalCurrentLine:(NSString *)sender expressions:(NSArray **)expressions {
    RispContext *context = [RispContext currentContext];
    RispReader *_reader = [[RispReader alloc] initWithContent:sender fileNamed:@"RispREPL"];
    id value = nil;
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSMutableArray *exprs = nil;

    if (expressions) {
        exprs = [[NSMutableArray alloc] init];
        *expressions = exprs;
    }
    while (![_reader isEnd]) {
        @autoreleasepool {
            @try {
                value = [_reader readEofIsError:YES eofValue:nil isRecursive:YES];
                [[_reader reader] skip];
                if (value == _reader) {
                    continue;
                }
                id expr = [RispCompiler compile:context form:value];
                if (exprs || expr) {
                    [exprs addObject:expr];
                }
                id v = [expr eval];
                //                id v = nil;
                [values addObject:v ? : [NSNull null]];
                
                if ([expr conformsToProtocol:@protocol(RispExpression)]) {
                    NSLog(@"%@ -\n%@\n-> %@", value, [[[RispAbstractSyntaxTree alloc] initWithExpression:expr] description], v);
                } else {
                    NSLog(@"%@ -\n%@\n-> %@", value, [RispAbstractSyntaxTree descriptionAppendIndentation:0 forObject:expr], v);
                }
            }
            @catch (NSException *exception) {
                [exprs addObject:exception];
                NSLog(@"%@ - %@\n%@", value, exception, [exception callStackSymbols]);
            }
        }
    }
    return values;
}

@end
