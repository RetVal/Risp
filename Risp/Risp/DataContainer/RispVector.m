//
//  RispVector.m
//  Risp
//
//  Created by closure on 4/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispVector.h"
#include <objc/runtime.h>
#import <Risp/RispRuntime.h>
#import <Risp/RispFnExpression.h>
#import <Risp/RispMethodExpression.h>

@interface RispVector() {
    
}
@property (strong, nonatomic) NSMutableArray *list;
@end


static RispVector * __RispEmptyList = nil;
@implementation RispVector
+ (void)load {
    __RispEmptyList = [[RispVector alloc] initWithArray:@[]];
}

+ (id)listWithObjects:(id)object, ... {
    if (!object) {
        return [[RispVector alloc] initWithArray:@[]];
    }
    NSMutableArray *list = [[NSMutableArray alloc] init];
    va_list ap;
    va_start(ap, object);
    id o = object;
    do {
        [list addObject:o];
        o = va_arg(ap, id);
    } while (o);
    va_end(ap);
    return [[RispVector alloc] initWithArrayNoCopy:list];
}

+ (id)listWithObjectsFromArray:(NSArray *)array {
    if (!array) return nil;
    return [[RispVector alloc] initWithArray:array];
}

+ (id)listWithObjectsFromArrayNoCopy:(NSArray *)array {
    if (!array) return nil;
    return [[RispVector alloc] initWithArrayNoCopy:array];
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        _list = [array mutableCopy];
    }
    return self;
}

- (id)initWithArrayNoCopy:(NSMutableArray *)array {
    if (self = [super init]) {
        _list = array;
    }
    return self;
}

- (id)objectAtIndex:(NSUInteger)index {
    if (index < [_list count])
        return [_list objectAtIndex:index];
    return nil;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0) {
    return [self objectAtIndex:idx];
}

- (NSEnumerator *)objectEnumerator {
    return [_list objectEnumerator];
}

- (NSEnumerator *)reverseObjectEnumerator {
    return [_list reverseObjectEnumerator];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    return [_list countByEnumeratingWithState:state objects:buffer count:len];
}

- (NSArray *)array {
    return _list;
}

- (RispVector *)reverse {
    if ([_list count] == 0) {
        return [RispVector empty];
    } else if ([_list count] == 1) {
        return [self copy];
    }
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger cnt = [_list count] - 1;
    for (NSInteger i = cnt; i >= 0; i--) {
        [array addObject:_list[i]];
    }
    RispVector *r = [[RispVector alloc] initWithArrayNoCopy:array];
    return r;
}

- (id)nth:(NSUInteger)idx {
    return _list[idx];
}

- (id)copyWithZone:(NSZone *)zone {
    RispVector *copy = [[RispVector alloc] initWithArray:_list];
    return copy;
}

- (id)mutableCopy {
    return [self copyWithZone:nil];
}

- (NSString *)description {
    NSArray *descs = [RispRuntime map:_list fn:^id(id object) {
        return [object description];
    }];
    return [NSString stringWithFormat:@"[%@]", [descs componentsJoinedByString:@" "]];
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    [_list enumerateObjectsUsingBlock:block];
}

- (NSUInteger)count {
    return [_list count];
}

- (id)first {
    return [_list firstObject];
}

- (id)next {
    if ([_list count] < 2)
        return nil;
    NSMutableArray *copy = [_list mutableCopy];
    [copy removeObjectAtIndex:0];
    return [RispVector listWithObjectsFromArrayNoCopy:copy];
}

- (id)rest {
    return [self next];
}

- (id)last {
    return [_list lastObject];
}

- (id)drop:(NSNumber *)num {
    NSInteger n = [num integerValue];
    if (n >= [self count]) {
        return [RispVector empty];
    }
    NSMutableArray *array = [_list mutableCopy];
    [array removeObjectsInRange:NSMakeRange(0, n)];
    return [RispVector listWithObjectsFromArrayNoCopy:array];
}

+ (id)empty {
    return __RispEmptyList;
}

+ (id)creator {
    RispFnExpression *fn = [[RispFnExpression alloc] init];
    [fn setName:[RispSymbol named:@"vector"]];
    RispBlockExpression *method = [[RispBlockExpression alloc] initWithBlock:^id(RispVector *arguments) {
        return [RispVector listWithObjectsFromArrayNoCopy:[[arguments first] array]];
    } variadic:YES numberOfArguments:0];
    [fn setVariadicMethod:method];
    return fn;
}

- (BOOL)isEmpty {
    return [_list count] == 0 ? YES : NO;
}

- (id)cons:(id)o {
    RispVector *copy = [self copy];
    [copy->_list insertObject:o atIndex:0];
    return copy;
}

- (id)conj:(id)o {
    RispVector *copy = [self copy];
    [copy->_list addObject:o];
    return copy;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _list;
}

- (id)second {
    return [_list count] > 1 ? _list[1] : nil;
}
@end
