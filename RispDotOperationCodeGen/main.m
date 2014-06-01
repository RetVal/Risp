//
//  main.m
//  RispDotOperationCodeGen
//
//  Created by closure on 4/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RispDotOperationCodeGen : NSObject
+ (NSString *)genMax:(NSInteger)max vectorNamed:(NSString *)name;
@end

@implementation RispDotOperationCodeGen

+ (NSString *)genMax:(NSInteger)max vectorNamed:(NSString *)name {
    NSString * const countOfArgumentsFormat = @"NSInteger countOfArguments = [%@ count];\n";
    NSString * const vCallStartFormat = @"\tcase %ld:\n\t\treturn objc_msgSend(_target, _selector, %@);\n";
    NSString * const countOfArguments = [NSString stringWithFormat:countOfArgumentsFormat, name];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:max];
    
    if (max >= 0) {
        [result addObject:countOfArguments];
        [result addObject:@"switch (countOfArguments) {\n"];
        NSString *content = [[NSString alloc] initWithFormat:@"\tcase 0:\n\t\treturn objc_msgSend(_target, _selector);\n"];
        [result addObject:content];
    }
    for (NSInteger start = 1; start < max; start ++) {
        NSMutableString *content = [[NSMutableString alloc] init];
        if (start > 1) {
            [content appendFormat:@"%@[%d], ", name, 0];
        }
        for (NSInteger idx = 1; idx < start - 1; idx++) {
            [content appendFormat:@"%@[%ld], ", name, idx];
        }
        [content appendFormat:@"%@[%ld]", name, start - 1];
        [result addObject:[NSString stringWithFormat:vCallStartFormat, start, content]];
    }
    
    if (max >= 0) {
        [result addObject:@"\tdefault:\n\t\treturn nil;\n"];
        [result addObject:@"}\n"];
    }
    return [result componentsJoinedByString:@""];
}

@end

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        NSLog(@"Hello, World!");
        [[RispDotOperationCodeGen genMax:30 vectorNamed:@"_arguments"] writeToFile:[@"~/Desktop/dot.m" stringByStandardizingPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    return 0;
}

