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

- (id)withMeta:(id)value forKey:(id)key {
    NSMutableDictionary *dict = (NSMutableDictionary *)[self meta];
    [dict setObject:value forKey:key];
    return self;
}

@end
