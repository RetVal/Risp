//
//  RispKeyword.m
//  Risp
//
//  Created by closure on 4/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispKeyword.h"
//#include <libkern/OSAtomic.h>
//static NSMutableDictionary *__RispKeywordTable = nil;
//static OSSpinLock __RispKeywordTableLock = OS_SPINLOCK_INIT;
//
//static void __RispKeywordUpdate(NSString *string, RispKeyword *symbol) {
//    if (!string) return;
//    OSSpinLockLock(&__RispKeywordTableLock);
//    if (!__RispKeywordTable) {
//        __RispKeywordTable = [[NSMutableDictionary alloc] init];
//    }
//    __RispKeywordTable[string] = symbol;
//    OSSpinLockUnlock(&__RispKeywordTableLock);
//}
//
//static id __RispKeywordFind(NSString *string) {
//    if (!string) return nil;
//    OSSpinLockLock(&__RispKeywordTableLock);
//    id v = __RispKeywordTable[string];
//    OSSpinLockUnlock(&__RispKeywordTableLock);
//    return v;
//}

@implementation RispKeyword
+ (id)named:(NSString *)name {
//    return __RispKeywordFind(name) ? : [[RispKeyword alloc] initWithString:name];
    return [[RispKeyword alloc] initWithString:name];
}

+ (BOOL)isKeyword:(NSString *)object {
    return [object characterAtIndex:0] == ':';
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (BOOL)isEqualTo:(id)object {
    if ([object isMemberOfClass:[RispKeyword class]]) {
        return [[self stringValue] isEqualToString:[object stringValue]];
    } else if ([object isMemberOfClass:[NSString class]]) {
        return [[self stringValue] isEqualToString:object];
    } else if ([object isMemberOfClass:[RispSymbol class]]) {
        return [[self stringValue] isEqualToString:[object stringValue]];
    }
    return NO;
}

- (id)initWithString:(NSString *)string {
    if (!string)
        return nil;
    if (self = [super init]) {
        _stringValue = [string copy];
        _hashCode = [_stringValue hash];
//        __RispKeywordUpdate(string, self);
    }
    return self;
}

- (NSUInteger)hash {
    return _hashCode;
}
@end
