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
    NSString * const vCallStartFormat = @" else if ([%@ count] == %ld) {\n\treturn objc_msgSend(_target, _selector, %@);\n}";
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:max];
    if (max >= 0) {
        NSString * content = [[NSString alloc] initWithFormat:@"if ([%@ count] == %d) {\n\treturn objc_msgSend(_target, _selector);\n}", name,  0];
        [result addObject:content];
    }
    for (NSInteger start = 1; start < max; start ++) {
        NSMutableString *content = [[NSMutableString alloc] init];
        if (start) {
            [content appendFormat:@"[%@ first]", name];
        }
        if (start > 1) {
            [content appendString:@", "];
        }
        for (NSInteger idx = 1; idx < start - 1; idx++) {
            [content appendFormat:@"[(%@ = [%@ next]) first], ", name, name];
        }
        if (start > 1) {
            [content appendFormat:@"[(%@ = [%@ next]) first]", name, name];
        }
        [result addObject:[NSString stringWithFormat:vCallStartFormat, name, start, content]];
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

