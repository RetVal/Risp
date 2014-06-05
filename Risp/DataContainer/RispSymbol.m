//
//  RispSymbol.m
//  Risp
//
//  Created by closure on 4/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispSymbol.h>

static NSMutableDictionary *__RispSymbolTable = nil;
static OSSpinLock __RispSymbolTableLock = OS_SPINLOCK_INIT;

static void __RispSymbolUpdate(NSString *string, RispSymbol *symbol) {
    if (!string) return;
    OSSpinLockLock(&__RispSymbolTableLock);
    if (!__RispSymbolTable) {
        __RispSymbolTable = [[NSMutableDictionary alloc] init];
    }
    __RispSymbolTable[string] = symbol;
    OSSpinLockUnlock(&__RispSymbolTableLock);
}

static id __RispSymbolFind(NSString *string) {
    if (!string) return nil;
    OSSpinLockLock(&__RispSymbolTableLock);
    id v = __RispSymbolTable[string];
    OSSpinLockUnlock(&__RispSymbolTableLock);
    return v;
}

@implementation RispSymbol

+ (id)named:(NSString *)name {
//    return __RispSymbolFind(name) ? : [[RispSymbol alloc] initWithString:name];
    return [[RispSymbol alloc] initWithString:name];
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id)initWithString:(NSString *)string {
    if (!string)
        return nil;
    if (self = [super init]) {
        _stringValue = [string copy];
        _hashCode = [_stringValue hash];
//        __RispSymbolUpdate(string, self);
    }
    return self;
}

- (NSString *)description {
    return [_stringValue description];
}

- (NSUInteger)count {
    return [_stringValue length];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (BOOL)isEqual:(id)object {
    return [self isEqualTo:object];
}

- (BOOL)isEqualTo:(id)object {
    if ([object isMemberOfClass:[NSString class]]) {
        return [[self stringValue] isEqualToString:object];
    } else if ([object isMemberOfClass:[RispSymbol class]]) {
        return [[self stringValue] isEqualToString:[object stringValue]];
    }
    return NO;
}

- (NSUInteger)length {
    return [self count];
}

- (NSUInteger)hash {
    return _hashCode;
}
@end
