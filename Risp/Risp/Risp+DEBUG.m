//
//  Risp+DEBUG.m
//  Risp
//
//  Created by closure on 5/26/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "Risp+DEBUG.h"

@implementation NSObject (Debug)

- (NSString *)rispLocationInfomation {
    if ([self hasMeta]) {
        NSString *string = [[NSString alloc] initWithFormat:@"<file: %@, start: %ld, end: %ld, line: %ld, column: %ld>",
                            [self file],
                            [self start],
                            [self end],
                            [self lineNumber],
                            [self columnNumber]];
        return string;
    }
    return @"";
}

@end

@implementation Risp (Debug)
+ (NSString *)decriptionForExpression:(id <RispExpression>)expression {
    return [expression description];
}

+ (void)show:(id)object {
    NSLog(@"%@", object);
    return;
}
@end

#if TARGET_OS_IPHONE
@implementation NSObject (className)

- (NSString *)className {
    return NSStringFromClass([self class]);
}

- (BOOL)isEqualTo:(id)object {
    if ([self isKindOfClass:[NSString class]] && [object isKindOfClass:[NSString class]]) {
        return [(NSString *)self compare:object options:0] == 0;
    } else if ([self isKindOfClass:[NSNumber class]] && [object isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)self compare:object];
    } else if ([self isKindOfClass:[NSDate class]] && [object isKindOfClass:[NSDate class]]) {
        return [(NSDate *)self compare:object];
    }
    return self == object;
}

@end
#endif