//
//  RispLexicalScope.m
//  Syrah
//
//  Created by closure on 4/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispLexicalScope.h>
#import <Risp/RispToken.h>
#import <libKern/OSAtomic.h>
#import <Risp/RispContext.h>

@interface NSThread (RispContext)
+ (RispContext *)mainContext;
+ (RispContext *)currentContext;
- (RispContext *)threadContext;
- (void)setThreadContext:(RispContext *)context;
@end

@interface RispLexicalScope() {
    @private
    OSSpinLock _lock;
    __strong NSMutableDictionary *_scope;
    __weak RispLexicalScope *_outer;
    __strong RispLexicalScope *_inner;
    NSUInteger _depth;
}

@end

@implementation RispLexicalScope

+ (id)alloc {
    id x = [super alloc];
//    NSLog(@"alloc lexical scope %p", x);
    return x;
}

- (id)init {
    _depth = 0;
    return [self initWithParent:nil child:nil];
}

- (id)initWithParent:(RispLexicalScope *)outer {
    return [self initWithParent:outer child:nil];
}

- (id)initWithParent:(RispLexicalScope *)outer child:(RispLexicalScope *)inner {
    if (self = [super init]) {
        _depth = 0;
        _scope = [[NSMutableDictionary alloc] init];
        _inner = inner;
        _outer = outer;
//        _outer = [outer retain];
        if (outer) {
            OSSpinLockLock(&outer->_lock);
            _depth = _outer->_depth + 1;
            if (outer->_inner)
                outer->_inner = nil;
            outer->_inner = self;
            OSSpinLockUnlock(&outer->_lock);
        }
    }
    return self;
}

- (void)dealloc {
    OSSpinLockLock(&_lock);
    
//    [_scope release];
    _scope = nil;
    
//    [_inner release];
    _inner = nil;
    
//    [_exception release];
    _exception = nil;
    
    if (_outer) {
        _outer->_inner = nil;
    }
    OSSpinLockUnlock(&_lock);
//    [super dealloc];
}

- (id)objectForKey:(RispSymbol *)symbol {
    OSSpinLockLock(&_lock);
    id v = _scope[symbol];
    if (v) {
        OSSpinLockUnlock(&_lock);
        return v;
    }
    v = [[self outer] objectForKey:symbol];
    OSSpinLockUnlock(&_lock);
    return v;
}

- (void)setObject:(id)object forKey:(RispSymbol <NSCopying> *)aKey {
    OSSpinLockLock(&_lock);
    if (object == nil) {
        [_scope removeObjectForKey:aKey];
        OSSpinLockUnlock(&_lock);
        return;
    }
    [_scope setObject:object forKey:aKey];
    OSSpinLockUnlock(&_lock);
}

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(RispToken <NSCopying>*)key {
    [self setObject:obj forKey:key];
}

- (NSArray *)keys {
    OSSpinLockLock(&_lock);
    NSArray *keys = [_scope allKeys];
    OSSpinLockUnlock(&_lock);
    return keys;
}

- (NSArray *)values {
    OSSpinLockLock(&_lock);
    NSArray *keys = [_scope allValues];
    OSSpinLockUnlock(&_lock);
    return keys;
}

- (NSString *)description {
    return [_scope description];
}

- (RispLexicalScope *)outer {
    return _outer;
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

+ (RispLexicalScope *)_copySingle:(RispLexicalScope *)scope {
    RispLexicalScope *copy = [[RispLexicalScope alloc] init];
    copy->_scope = [scope->_scope mutableCopy];
    copy->_exception = [scope->_exception mutableCopy];
    copy->_depth = scope->_depth;
    return copy;
}

- (id)copyWithZone:(NSZone *)zone {
    /*
     RSLexicalScopingRef scope = (RSLexicalScopingRef)rs;
     struct __RSLexicalScoping *copy = (struct __RSLexicalScoping *)RSLexicalScopingCreate(allocator, nil, nil);
     copy->_depth = scope->_depth;
     copy->_scoping = (RSMutableDictionaryRef)RSRetain(scope->_scoping);
     copy->_outer = scope->_outer ? RSCopy(allocator, scope->_outer) : nil;
     return copy;
     */
    
    OSSpinLockLock(&_lock);
    RispLexicalScope *copy = [[RispLexicalScope alloc] init];
    copy->_depth = _depth;
    copy->_scope = [_scope mutableCopy];
//    copy->_outer = [_outer mutableCopy];
    if (copy->_depth && copy->_outer != nil) {
        copy->_outer->_inner = copy;
    }
    OSSpinLockUnlock(&_lock);
    return copy;
//    
//    NSUInteger depth = _depth;
//    RispLexicalScope *root = self;
//    while (root->_depth) {
//        root = root->_outer;
//    }
//    copy = [RispLexicalScope _copeSingle:root];
//    copy->_outer = nil;
//    RispLexicalScope *skip = copy;
//    for (NSUInteger idx = 1; idx <= depth; idx++) {
//        root = root->_inner;
//        skip->_inner = [RispLexicalScope _copeSingle:root];
//        skip->_inner->_outer = skip;
//        skip = skip->_inner;
//    }
//    
//    return copy;
}

- (id)mutableCopy {
    return [self copy];
}
@end
