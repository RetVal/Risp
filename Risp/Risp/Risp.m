//
//  Risp.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>
#import "Risp+DEBUG.h"
#import "NSDecimalNumber+Math.h"

@interface NSObject (String)
- (NSString *)stringValue;
@end

@implementation NSObject (String)

- (NSString *)stringValue {
    return [self description];
}

@end

@implementation Risp

+ (void)load {
    RispReader *reader = [[RispReader alloc] initWithContentsOfFile:[[NSBundle bundleWithIdentifier:@"com.retval.Risp"] pathForResource:@"init" ofType:@"risp"]];
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

+ (id)eval:(id)object {
    id <RispExpression> expr = nil;
    if (![object conformsToProtocol:@protocol(RispExpression)]) {
        expr = [RispCompiler compile:[RispContext currentContext] form:object];
    }
    return [expr eval];
}

@end