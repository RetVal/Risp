//
//  RispLexicalScope.m
//  Syrah
//
//  Created by closure on 4/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispLexicalScope.h>
#import <Risp/RispToken.h>

@interface RispLexicalScope() {
    @private
    __strong NSMutableDictionary *_scope;
}

@end

@implementation RispLexicalScope
- (id)init {
    _depth = 0;
    return [self initWithParent:nil child:nil];
}

- (id)initWithParent:(RispLexicalScope *)outer {
    return [self initWithParent:outer child:nil];
}

- (id)initWithParent:(RispLexicalScope *)outer child:(RispLexicalScope *)inner {
    if (self = [super init]) {
        _scope = [[NSMutableDictionary alloc] init];
        _outer = outer;
        _inner = inner;
        _depth = _outer ? _outer->_depth + 1 : 0;
    }
    return self;
}

- (void)dealloc {
    _inner = nil;
    _scope = nil;
    if (_outer) {
        _outer->_exception = _exception;
        _outer->_inner = nil;
        _outer = nil;
    }
}

- (id)objectForKey:(RispSymbol *)symbol {
    id v = _scope[symbol];
    if (v)
        return v;
    return [[self outer] objectForKey:symbol];
}

- (void)setObject:(id)object forKey:(RispSymbol <NSCopying> *)aKey {
    if (object == nil)
        return [_scope removeObjectForKey:aKey];
    [_scope setObject:object forKey:aKey];
}

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(RispToken <NSCopying>*)key {
    [self setObject:obj forKey:key];
}

- (NSArray *)keys {
    return [_scope allKeys];
}

- (NSArray *)values {
    return [_scope allValues];
}

- (NSString *)description {
    return [_scope description];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _scope = [aDecoder decodeObject];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_scope];
}

- (id)copyWithZone:(NSZone *)zone {
    RispLexicalScope *copy = [[RispLexicalScope alloc] init];
    copy->_outer = _outer;
    copy->_inner = _inner;
    copy->_scope = [_scope copy];
    copy->_exception = _exception;
    copy->_depth = _depth;
    return copy;
}
@end
