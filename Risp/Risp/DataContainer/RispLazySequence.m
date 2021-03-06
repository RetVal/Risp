    //
//  RispLazySequence.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispLazySequence.h"

@interface RispLazySequence ()
@property (nonatomic, strong, readonly) id fn;
@property (nonatomic, strong, readonly) id sv;
@property (nonatomic, strong, readonly) id <RispSequence> s;
@property (nonatomic, assign, readonly, getter = isClosure) BOOL closure;
@end

@implementation RispLazySequence
- (id)initWithFn:(RispFnExpression *)fn {
    if (self = [super init]) {
        _fn  = fn;
        _closure = NO;
    }
    return self;
}

- (id)initWithSeq:(id <RispSequence>)s {
    if (self = [super init]) {
        _fn = nil;
        _s = s;
    }
    return self;
}

- (id)initWithClosure:(RispClosureExpression *)closure {
    if (self = [super init]) {
        _fn = closure;
        _closure = YES;
    }
    return self;
}

- (id)sval {
    @synchronized(self) {
        if (_fn) {
            if ([self isClosure]) {
                _sv = [[_fn applyTo:[RispVector empty]] eval];
            } else {
                _sv = [[[_fn methodForCountOfArgument:0] applyTo:[RispVector empty]] eval];
            }
            _fn = nil;
        }
        if (_sv)
            return _sv;
    }
    return _s;
}

- (id <RispSequence>)seq {
    [self sval];
    @synchronized(self) {
        if (_sv) {
            id ls = _sv;
            _sv = nil;
            while ([ls isKindOfClass:[RispLazySequence class]]) {
                ls = [ls sval];
            }
            _s = ls;
        }
    }
    return [RispSequence sequence:_s];
}

- (NSUInteger)count {
    NSUInteger count = 0;
    for (id <RispSequence> s = [self seq]; s; s = [s next]) {
        ++count;
    }
    return count;
}

- (id)first {
    [self seq];
    if (!_s) return nil;
    return [_s first];
}

- (id)next {
    [self seq];
    if (!_s) return nil;
    return [_s next];
}

- (BOOL)isEqualTo:(id)object {
    return YES;
}

- (NSArray *)array {
    return [[self seq] array];
}

- (BOOL)isEmpty {
    return [self seq] == nil;
}

- (id)cons:(id)o {
    [NSException raise:RispRuntimeException format:@"Unsupport cons in lazy-seq"];
    return nil;
}

- (id)conj:(id)o {
    [NSException raise:RispRuntimeException format:@"Unsupport conj in lazy-seq"];
    return nil;
    NSArray *array = nil;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
    }];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    return 0;
}

+ (id)creator {
    RispFnExpression *fn = [RispFnExpression blockWihObjcBlock:^id(RispVector *arguments) {
        id first = [arguments first];
        if ([first isKindOfClass:[RispFnExpression class]]) {
            return [[RispLazySequence alloc] initWithFn:first];
        } else if ([first conformsToProtocol:@protocol(RispSequence)]) {
            return [[RispLazySequence alloc] initWithSeq:[RispSequence sequence:first]];
        } else if ([first isKindOfClass:[RispClosureExpression class]]) {
            return [[RispLazySequence alloc] initWithClosure:first];
        }
        [NSException raise:RispInvalidNumberFormatException format:@""];
        return nil;
    } variadic:NO numberOfArguments:1];
    [fn setName:[RispSymbol named:@"lazy-seq"]];
    return fn;
}

- (id)eval {
    return [self seq];
}

- (NSString *)description {
    return [[self eval] description];
}

- (NSString *)descriptionWithLocale:(NSLocale *)locale {
    return [self description];
}

- (id)copyWithZone:(NSZone *)zone {
    RispLazySequence *copy = nil;
    if (_fn) {
        copy = [[RispLazySequence alloc] initWithFn:_fn];
    } else {
        copy = [[RispLazySequence alloc] initWithSeq:_s];
    }
    return copy;
}
@end
