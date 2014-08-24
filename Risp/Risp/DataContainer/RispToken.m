//
//  RispToken.m
//  Risp
//
//  Created by closure on 4/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispToken.h>
#include <libkern/OSAtomic.h>
static NSMutableDictionary *__RispTokenTable = nil;
static OSSpinLock __RispTokenTableLock = OS_SPINLOCK_INIT;

static void __RispTokenUpdate(NSString *string, RispToken *token) {
    if (!string) return;
    OSSpinLockLock(&__RispTokenTableLock);
    if (!__RispTokenTable) {
        __RispTokenTable = [[NSMutableDictionary alloc] init];
    }
    __RispTokenTable[string] = token;
    OSSpinLockUnlock(&__RispTokenTableLock);
}
//
//static RispToken *__RispTokenFind(NSString *string) {
//    if (!string) return nil;
//    OSSpinLockLock(&__RispTokenTableLock);
//    id v = __RispTokenTable[string];
//    OSSpinLockUnlock(&__RispTokenTableLock);
//    return v;
//}

@implementation RispToken

+ (id)named:(NSString *)name {
//    if (!name) return nil;
//    id v = __RispTokenFind(name);
//    if (v) return v;
    return [[RispToken alloc] initWithString:name];
}

- (id)initWithString:(NSString *)string {
    if (self = [super init]) {
        _stringValue = string;
        _hashCode = [_stringValue hash];
        __RispTokenUpdate(string, self);
    }
    return self;
}

- (BOOL)isEqualTo:(id)object {
    if ([object isMemberOfClass:[RispToken class]]) {
        return [[self stringValue] isEqualToString:[object stringValue]];
    } else if ([object isMemberOfClass:[NSString class]]) {
        return [[self stringValue] isEqualToString:object];
    } else if ([object isMemberOfClass:[RispSymbol class]]) {
        return [[self stringValue] isEqualToString:[object stringValue]];
    }
    return NO;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (NSUInteger)hash {
    return _hashCode;
}

- (NSString *)description {
    return _stringValue;
}

- (NSUInteger)count {
    return [_stringValue length];
}
@end
