//
//  Risp.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>
#import "Risp+DEBUG.h"

@implementation Risp

+ (void)load {
    RispReader *reader = [[RispReader alloc] initWithContentOfFile:[[NSBundle bundleWithIdentifier:@"com.retval.Risp"] pathForResource:@"init" ofType:@"risp"]];
    RispContext *context = [RispContext currentContext];
    id value = nil;
    NSMutableArray *values = [[NSMutableArray alloc] init];
    while (![reader isEnd]) {
        @autoreleasepool {
            @try {
                value = [reader readEofIsError:YES eofValue:nil isRecursive:YES];
                [[reader reader] skip];
                if (value == reader) {
                    continue;
                }
                id expr = [RispCompiler compile:context form:value];
                id v = [expr eval];
                //                id v = nil;
                NSLog(@"%@ -\n%@\n-> %@", value, [[[RispAbstractSyntaxTree alloc] initWithExpression:expr] description], v);
                [values addObject:v ? : [NSNull null]];
            }
            @catch (NSException *exception) {
                NSLog(@"exception: %@ - %@", value, exception);
            }
        }
    }
}

@end