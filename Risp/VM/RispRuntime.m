//
//  RispRuntime.m
//  Syrah
//
//  Created by closure on 4/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispRuntime.h>
#import <Risp/RispList.h>
#import <Risp.h>

@interface RispRuntime() {
    
}
@end
@implementation RispRuntime
+ (void)load {
    RispLexicalScope *rootScope = [[RispRuntime baseEnvironment] rootScope];
}

- (id)init {
    if (self = [super init]) {
        _rootScope = [[RispLexicalScope alloc] init];
    }
    return self;
}

+ (id)map:(id)object fn:(id (^)(id object))fn {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [array addObject:fn(obj) ? : [NSNull null]];
    }];
    return [[[object class] alloc] initWithArray:array];
}

+ (void)apply:(id)object fn:(id (^)(id object))fn {
    [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        fn(obj);
    }];
}

+ (id)filter:(id)object pred:(id (^)(id object))pred {
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([pred(obj) booleanValue]) {
            [indexSet addIndex:idx];
        }
    }];
    RispList *list = [[RispList alloc] initWithArray:[object objectsAtIndexes:indexSet]];
    return list;
}

+ (id)remove:(id)object pred:(id (^)(id object))pred {
    return [self filter:object pred:^id(id object) {
        return @(![pred(object) booleanValue]);
    }];
}

+ (instancetype)baseEnvironment {
    static dispatch_once_t onceToken;
    static RispRuntime *runtime;
    dispatch_once(&onceToken, ^{
        runtime = [[RispRuntime alloc] init];
    });
    return runtime;
}

+ (NSRange)rangeForDefaultArugmentsNumber {
    return NSMakeRange(0, 1);
}

+ (NSRange)rangeForDefaultArugmentsNumberWithUnlimit {
    return NSMakeRange(0, -1);
}

+ (id <RispSequence>)sequence:(id)object {
    if ([object isKindOfClass:[RispSequence class]]) {
        return object;
    } else if ([object isKindOfClass:[RispVector class]]) {
        return [[RispList alloc] initWithArray:[object array]];
    } else if ([object isKindOfClass:[NSString class]]) {
        return [[RispList alloc] initWithArray:[object array]];
    }
    return nil;
}

- (BOOL)registerSymbol:(RispSymbol *)symbol forObject:(id)object {
    if (!symbol)
        return NO;
    _rootScope[symbol] = object;
    return YES;
}
@end

NSString * const RispRuntimeException = @"RispRuntimeException";
NSString * const RispInvalidNumberFormatException = @"RispInvalidNumberFormatException";
NSString * const RispIllegalArgumentException = @"RispIllegalArgumentException";
