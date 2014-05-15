//
//  RispMap.m
//  Risp
//
//  Created by closure on 5/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispVector.h>
#import "RispMap.h"
#include <objc/runtime.h>
#include <objc/Protocol.h>
#include <Risp/RispRuntime.h>

@interface RispKVBucket : NSObject
+ (id)bucketWithValue:(id)value forKey:(id)key;
@end

@implementation RispKVBucket

+ (id)bucketWithValue:(id)value forKey:(id)key {
    RispVector *vector = [[RispVector alloc] initWithArray:@[key, value]];
    return vector;
}

@end

static RispMap *__RispEmptyMap;
@interface RispMap() {
    RispList *_seq;
}
@property (nonatomic, strong, readonly) NSMutableDictionary *dictionary;
@property (nonatomic, strong, readonly) RispList *seq;
- (void)_init;
@end

@implementation RispMap

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __RispEmptyMap = [[RispMap alloc] init];
    });
}

+ (instancetype)mapWithSequence:(id <RispSequence>)seq {
    RispMap *map = [[RispMap alloc] initWithSequence:seq];
    return map;
}

- (id)init {
    if (self = [super init]) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithSequence:(id<RispSequence>)seq {
    if (!seq || [seq count] == 0) return [RispMap empty];
    if ([seq count] & 0x1) {
        [NSException raise:RispIllegalArgumentException format:@"%@ must be even", seq];
    }
    if (self = [super init]) {
        [self _init];
        
        while (seq) {
            RispKeyword *key = [seq first];
            seq = [seq next];
            id v = [seq first];
            seq = [seq next];
            _dictionary[key] = v;
        }
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [_dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [array addObject:[RispVector  listWithObjects:key, obj, nil]];
        }];
        _seq = [[RispList alloc] initWithArray:array];
    }
    return self;
}

- (void)_init {
    _dictionary = [[NSMutableDictionary alloc] init];
}

- (NSUInteger)count {
    return [_dictionary count];
}

- (id)first {
    return [_seq first];
}

- (id)next {
    return [_seq next];
}

+ (id)empty {
    return __RispEmptyMap;
}

- (id<RispSequence>)seq {
    return _seq;
}

- (id)copyWithZone:(NSZone *)zone {
    RispMap *map = [[RispMap alloc] init];
    map->_dictionary = [_dictionary copy];
    map->_seq = [_seq copy];
    return map;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    struct objc_method_description md = protocol_getMethodDescription(@protocol(RispSequence), aSelector, YES, YES);
    if (md.name) {
        return _seq;
    }
    return _dictionary;
}

- (NSString *)description {
    return [_dictionary description];
}

@end
