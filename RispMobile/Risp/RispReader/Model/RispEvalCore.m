//
//  RispEvalCore.m
//  Risp
//
//  Created by closure on 7/16/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispEvalCore.h"

@implementation RispEvalCore
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
//                ASUserNotification *notification = [[ASUserNotification alloc] init];
//                [notification setTitle:[exception name]];
//                [notification setSubtitle:[NSString stringWithFormat:@"%@", value]];
//                [notification setInformativeText:[NSString stringWithFormat:@"%@", exception]];
//                [notification setHasActionButton: NO];
//                [[ASUserNotificationCenter customUserNotificationCenter] deliverNotification:notification];
                NSLog(@"%@ - %@\n%@", value, exception, [exception callStackSymbols]);
            }
        }
    }
    return values;
}

@end
