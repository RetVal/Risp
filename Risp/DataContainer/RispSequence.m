//
//  RispSequence.m
//  Risp
//
//  Created by closure on 4/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispSequence.h>
#import <Risp/RispRuntime.h>
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
    return _next;
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

- (id)drop:(NSUInteger)n {
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
    while (!stop && x) {
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
    if ([object isKindOfClass:[RispSequence class]] || [object conformsToProtocol:NSProtocolFromString(@"RispSequence")]) {
        id <RispSequence> x = self;
        id <RispSequence> y = object;
        if ([x count] != [y count]) {
            return NO;
        } else {
            while (x && y) {
                if (NO == [[x first] isEqualTo:[y first]]) {
                    return NO;
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

@end
