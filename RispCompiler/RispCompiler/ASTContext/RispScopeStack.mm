//
//  RispScopeStack.m
//  RispCompiler
//
//  Created by closure on 8/21/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispScopeStack.h"
#import <Risp/RispSymbolExpression.h>
#include "llvm/Support/raw_os_ostream.h"

namespace RispLLVM {
    
    class RispObject {
    public:
        RispObject() : _object(nil) {
            
        }

        RispObject(id object) : _object (object) {
//            printf("RispObject(%s) %p\n", [[_object description] UTF8String], this);
        }
        
        RispObject(const RispObject &) = default;
        RispObject& operator=(const RispObject&) = default;
        
        ~RispObject() {
            if (_object) {
//                printf("~RispObject(%s) %p\n", [[_object description] UTF8String], this);
            }
        }
        
        static inline RispLLVM::RispObject *getEmptyMarkerPtr() {
            static RispLLVM::RispObject _emptyMarker;
            return &_emptyMarker;
        }
        
        static inline RispLLVM::RispObject *getTombstoneMarkerPtr() {
            static RispLLVM::RispObject _tombstoneMarker;
            return &_tombstoneMarker;
        }
        
        static inline RispLLVM::RispObject getEmptyMarker() {
            static RispLLVM::RispObject _emptyMarker;
            return _emptyMarker;
        }
        
        static inline RispLLVM::RispObject getTombstoneMarker() {
            static RispLLVM::RispObject _tombstoneMarker;
            return _tombstoneMarker;
        }
        
        id getObject() const {
            return _object;
        }
        
        void setObject(RispSymbolExpression *symbolExpression) {
            _object = symbolExpression;
        }
        
        bool isValid() const {
            return _object != nil;
        }
        
    public:
        typedef llvm::DenseMap<RispLLVM::RispObject, llvm::Value *> RispLLVMDenseObjectMap;
    private:
        __strong RispSymbolExpression *_object;
    };
}

template <>
struct llvm::DenseMapInfo<RispLLVM::RispObject> {
    static inline RispLLVM::RispObject getEmptyKey() {
        return RispLLVM::RispObject::getEmptyMarker();
    }
    static inline RispLLVM::RispObject getTombstoneKey() {
        return RispLLVM::RispObject::getTombstoneMarker();
    }
    
    static unsigned getHashValue(RispLLVM::RispObject S) {
        return (unsigned)[S.getObject() hash];
    }
    
    static bool isEqual(RispLLVM::RispObject LHS, RispLLVM::RispObject RHS) {
        if (LHS.getObject() == RHS.getObject()) {
            return true;
        }
        return [LHS.getObject() isEqualTo:RHS.getObject()];
    }
};

template <>
struct llvm::DenseMapInfo<RispLLVM::RispObject *> {
    static inline RispLLVM::RispObject *getEmptyKey() {
        return RispLLVM::RispObject::getEmptyMarkerPtr();
    }
    static inline RispLLVM::RispObject *getTombstoneKey() {
        return RispLLVM::RispObject::getTombstoneMarkerPtr();
    }
    
    static unsigned getHashValue(RispLLVM::RispObject *S) {
        return (unsigned)[S->getObject() hash];
    }
    
    static bool isEqual(RispLLVM::RispObject *LHS, RispLLVM::RispObject *RHS) {
        if (LHS->getObject() == RHS->getObject()) {
            return true;
        }
        return [LHS->getObject() isEqualTo:RHS->getObject()];
    }
};

@interface RispScopeStack () {
@private
    RispLLVM::RispLLVMValueMeta::RispLLVMDenseMetaMap _metaScope;
    RispLLVM::RispObject::RispLLVMDenseObjectMap _scope;    // symbol expression - llvm::Value *
    OSSpinLock _lock;
    __weak RispScopeStack *_outer;
    __strong RispScopeStack *_inner;
    NSUInteger _depth;
}
@end

@implementation RispScopeStack

+ (id)alloc {
    id x = [super alloc];
    //    NSLog(@"alloc lexical scope %p", x);
    return x;
}

- (id)init {
    return [self initWithParent:nil child:nil];
}

- (id)initWithParent:(RispScopeStack *)outer {
    return [self initWithParent:outer child:nil];
}

- (id)initWithParent:(RispScopeStack *)outer child:(RispScopeStack *)inner {
    if (self = [super init]) {
        _depth = 0;
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
//    _scope = nil;
    
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

- (llvm::Value *)_objectForKey:(RispLLVM::RispObject *)aKey depth:(NSUInteger *)depth {
    OSSpinLockLock(&_lock);
    llvm::Value *v = _scope.lookup(*aKey);
    if (v) {
        if (depth) {
            *depth = _depth;
        }
        OSSpinLockUnlock(&_lock);
        return v;
    }
    v = [[self outer] _objectForKey:aKey depth:depth];
    OSSpinLockUnlock(&_lock);
    return v;
}

- (llvm::Value *)objectForKey:(RispSymbolExpression *)aKey {
    return [self objectForKey:aKey atDepth:nil];
}

- (llvm::Value *)objectForKey:(RispSymbolExpression *)aKey atDepth:(NSUInteger *)depth {
    RispLLVM::RispObject k = RispLLVM::RispObject(aKey);
    llvm::Value *v = [self _objectForKey:&k depth:depth];
    return v;
}

- (void)setObject:(llvm::Value *)object forKey:(RispSymbolExpression *)aKey {
    OSSpinLockLock(&_lock);
    
    if (object == nil) {
        RispLLVM::RispObject k(aKey);
        _scope.erase(k);
        OSSpinLockUnlock(&_lock);
        return;
    }
    RispLLVM::RispObject k = RispLLVM::RispObject(aKey);
    _scope[k] = object;
    OSSpinLockUnlock(&_lock);
}

- (RispLLVM::RispLLVMValueMeta)metaForValue:(llvm::Value *)aValue {
    OSSpinLockLock(&_lock);
    
    RispLLVM::RispLLVMValueMeta v = _metaScope.lookup(aValue);
    if (v.isValid()) {
        OSSpinLockUnlock(&_lock);
        return v;
    }
    v = [[self outer] metaForValue:aValue];
    OSSpinLockUnlock(&_lock);
    return v;
}

- (void)setMeta:(RispLLVM::RispLLVMValueMeta)meta forValue:(llvm::Value *)aValue {
    OSSpinLockLock(&_lock);
    if (!meta.isValid()) {
        _metaScope.erase(aValue);
        OSSpinLockUnlock(&_lock);
        return;
    }
    _metaScope[aValue] = meta;
    OSSpinLockUnlock(&_lock);
}

- (NSArray *)keys {
    OSSpinLockLock(&_lock);
//    NSArray *keys = [_scope allKeys];
    NSArray *keys = @[];
    OSSpinLockUnlock(&_lock);
    return keys;
}

- (NSArray *)values {
    OSSpinLockLock(&_lock);
//    NSArray *keys = [_scope allValues];
    NSArray *values = @[];
    OSSpinLockUnlock(&_lock);
    return values;
}

- (NSString *)description {
    NSMutableString *desc = [[NSMutableString alloc] init];
    [desc appendString:@"{\n"];
    for (llvm::DenseMapIterator<RispLLVM::RispObject, llvm::Value *> i = _scope.begin(), e = _scope.end(); i != e; i++) {
        if (i->first.isValid()) {
            std::string content;
            llvm::raw_string_ostream sos(content);
            i->second->print(sos);
            [desc appendFormat:@"\t%@ : %@\n", [i->first.getObject() description], [NSString stringWithUTF8String:content.c_str()]];
        }
    }
    [desc appendString:@"}"];
    return desc;
}

- (RispScopeStack *)outer {
    return _outer;
}

+ (RispScopeStack *)_copySingle:(RispScopeStack *)scope {
    RispScopeStack *copy = [[RispScopeStack alloc] init];
    copy->_scope.copyFrom(scope->_scope);
    copy->_exception = [scope->_exception mutableCopy];
    copy->_depth = scope->_depth;
    return copy;
}

- (id)copyWithZone:(NSZone *)zone {
    OSSpinLockLock(&_lock);
    RispScopeStack *copy = [[RispScopeStack alloc] init];
    copy->_depth = _depth;
    copy->_scope.copyFrom(_scope);
    //    copy->_outer = [_outer mutableCopy];
    if (copy->_depth && copy->_outer != nil) {
        copy->_outer->_inner = copy;
    }
    OSSpinLockUnlock(&_lock);
    return copy;
}

- (id)mutableCopy {
    return [self copy];
}

- (llvm::Value *)objectForKeyedSubscript:(RispSymbolExpression *)key {
    return [self objectForKey:key];
}

- (void)setObject:(llvm::Value *)obj forKeyedSubscript:(RispSymbolExpression *)key {
    [self setObject:obj forKey:key];
}

- (BOOL)isCurrentScope:(NSUInteger)depth {
    return _depth == depth;
}
@end
