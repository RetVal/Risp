//
//  RispSequence.m
//  Risp
//
//  Created by closure on 4/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispSequence.h>
#import <Risp/RispRuntime.h>
#import <Risp/RispMap.h>
#import <objc/runtime.h>

@interface RispSequence () {
    @private
    RispSequence *_next;
}
@property (nonatomic, strong, readonly) id object;

@end

static RispSequence *__RispSequeuceEmpty = nil;
@implementation RispSequence
- (id)init {
    if (__RispSequeuceEmpty)
        return __RispSequeuceEmpty;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __RispSequeuceEmpty = self;
    });
    return __RispSequeuceEmpty;
}

+ (id)listWithObjects:(id)object, ... {
    if (!object) {
        return [[RispSequence alloc] initWithArray:@[]];
    }
    RispSequence *list = [[RispSequence alloc] init];
    va_list ap;
    va_start(ap, object);
    id o = object;
    do {
        list = [list cons:o];
        o = va_arg(ap, id);
    } while (o);
    va_end(ap);
    return list;
}

- (id)initWithObject:(id)object base:(RispSequence *)base {
    if (self = [super init]) {
        _object = object;
        _next = base;
        _count = [base count] + 1;
    }
    return self;
}

- (id)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        NSEnumerator *enumerator = [array reverseObjectEnumerator];
        RispSequence *seq = [[RispSequence alloc] init];
        for (id o in enumerator) {
            seq = [seq cons:o];
        }
        _object = [seq first];
        _next = [seq next];
        _count = [seq count];
        seq = nil;
    }
    return self;
}

- (id)first {
    return _object;
}

- (id)second {
    return [_next first];
}

- (id)rest {
    return _next ? : [RispSequence empty];
}

- (id)last {
    id x = self;
    NSInteger cnt = [x count] - 1;
    while (cnt > 0 && [x next]) {
        x = [x next];
        cnt --;
    }
    return [x object];
}

- (id)drop:(NSNumber *)num {
    NSInteger n = [num integerValue];
    if (!n) return nil;
    if (n == _count)
        return [[RispSequence alloc] init];
    RispSequence *x = [self copy];
    x->_count -= n;
    RispSequence *node = x;
    while (n == [node count] - 1) {
        node = [node next];
        node->_count -= n;
    }
    node->_next = nil;
    return x;
}

- (id)cons:(id)o {
    return [[RispSequence alloc] initWithObject:o base:self];
}

- (id)conj:(id)o {
    return [[RispSequence alloc] initWithObject:o base:self];
}

- (id)reverse {
    __block RispSequence *reverse = [[RispSequence alloc] init];
    [RispRuntime apply:self fn:^id(id object) {
        reverse = [reverse cons:object];
        return nil;
    }];
    return reverse;
}

- (id)copyWithZone:(NSZone *)zone {
    RispSequence *copy = [[RispSequence alloc] init];
    RispSequence * x = self;
    while (x) {
        copy = [copy cons:[[x next] first]];
        x = [x next];
    }
    return copy;
}

- (id)next {
    if (_next == __RispSequeuceEmpty)
        return nil;
    return _next;
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    BOOL stop = NO;
    RispSequence *x = self;
    while (!stop && [x first]) {
        block([x first], [self count] - [x count], &stop);
        x = [x next];
    }
}

- (NSArray *)array {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [RispRuntime apply:self fn:^id(id object) {
        [array addObject:object];
        return nil;
    }];
    return array;
}

- (BOOL)isEqualTo:(id)object {
    if ([object isKindOfClass:[RispSequence class]] || [object conformsToProtocol:@protocol(RispSequence)]) {
        id <RispSequence> x = self;
        id <RispSequence> y = object;
        if ([x count] != [y count]) {
            return NO;
        } else {
            while (x && y) {
                id fx = [x first];
                id fy = [y first];
                if (fx != fy) {
                    if (fx) {
                        if (NO == [fx isEqualTo:fy]) {
                            return NO;
                        }
                    }
                }
                x = [x next];
                y = [y next];
            }
            return YES;
        }
    }
    return NO;
}

+ (id)empty {
    return [[RispSequence alloc] init];
}

- (BOOL)isEmpty {
    return _count == 0;
}

- (NSString *)description {
    NSArray *descs = [[RispRuntime map:self fn:^id(id object) {
        return [object description];
    }] array];
    return [NSString stringWithFormat:@"(%@)", [descs componentsJoinedByString:@" "]];
}


- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    return [[self array] countByEnumeratingWithState:state objects:buffer count:len];
}

- (NSString *)stringValue {
    return [self description];
}
@end


#import <Risp/RispCharSequence.h>
#import <Risp/RispLazySequence.h>

@implementation RispSequence (Sequence)

+ (id <RispSequence>)sequence:(id)obj {
    if (!obj || [obj isKindOfClass:[NSNull class]]) {
        return nil;
    } else if ([obj isKindOfClass:[RispMap class]]) {
        return [obj seq];
    } else if ([obj conformsToProtocol:@protocol(RispSequence)]) {
        return [[RispSequence alloc] initWithArray:[obj array]];
    } else if ([obj isKindOfClass:[NSString class]]) {
        return [[RispCharSequence alloc] initWithString:obj];
    } else if ([obj isKindOfClass:[RispLazySequence class]]) {
        return [obj seq];
    } else if ([obj conformsToProtocol:@protocol(RispSequence)]) {
        return obj;
    }
    return [[RispSequence alloc] initWithObject:obj base:nil];
}

@end