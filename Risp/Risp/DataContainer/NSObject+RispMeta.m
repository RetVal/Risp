//
//  NSObject+RispMeta.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/NSObject+RispMeta.h>
#include <objc/runtime.h>

static char __RispMetaKey = 23;
@implementation NSObject (RispMeta)

- (NSDictionary *)meta {
    id o = objc_getAssociatedObject(self, &__RispMetaKey);
    if (!o) {
        objc_setAssociatedObject(self, &__RispMetaKey, o = [[NSMutableDictionary alloc] init], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return o;
}

- (BOOL)hasMeta {
    return objc_getAssociatedObject(self, &__RispMetaKey) != nil;
}

- (id)withMeta:(id)value forKey:(id)key {
    NSMutableDictionary *dict = (NSMutableDictionary *)[self meta];
    [dict setObject:value forKey:key];
    return self;
}

- (id)copyMetaFromObject:(id)object {
    id o = objc_getAssociatedObject(object, &__RispMetaKey);
    if (!o) return self;
    objc_setAssociatedObject(self, &__RispMetaKey, [o mutableCopy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return self;
}

@end

@implementation NSObject (RispDebugLocation)

- (NSString *)file {
    return [self meta][@"file"];
}

- (void)setFile:(NSString *)file {
    [self withMeta:file forKey:@"file"];
}

- (NSInteger)columnNumber {
    return [[self meta][@"columnNumber"] integerValue];
}

- (void)setColumnNumber:(NSInteger)columnNumber {
    [self withMeta:@(columnNumber) forKey:@"columnNumber"];
}

- (NSInteger)lineNumber {
    return [[self meta][@"lineNumber"] integerValue];
}

- (void)setLineNumber:(NSInteger)lineNumber {
    [self withMeta:@(lineNumber) forKey:@"lineNumber"];
}

- (NSInteger)start {
    return [[self meta][@"start"] integerValue];
}

- (void)setStart:(NSInteger)start{
    [self withMeta:@(start) forKey:@"start"];
}

- (NSInteger)end {
    return [[self meta][@"end"] integerValue];
}

- (void)setEnd:(NSInteger)end {
    [self withMeta:@(end) forKey:@"end"];
}

@end
