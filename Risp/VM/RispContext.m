//
//  RispContext.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispContext.h>
#import <Risp/RispDefExpression.h>
#import <Risp/RispDefnExpression.h>
#import <Risp/RispDotExpression.h>
#import <Risp/RispIfExpression.h>
#import <Risp/RispConstantExpression.h>
#import <Risp/RispLetExpression.h>

@interface NSThread (RispContext)
+ (RispContext *)mainContext;
+ (RispContext *)currentContext;
- (RispContext *)threadContext;
- (void)setThreadContext:(RispContext *)context;
@end

@interface NSMutableSet (KeyedSubscript)
- (id)objectForKeyedSubscript:(id)key NS_AVAILABLE(10_8, 6_0);
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key NS_AVAILABLE(10_8, 6_0);
@end

@implementation NSMutableSet (KeyedSubscript)

- (id)objectForKeyedSubscript:(id)key {
    return [self member:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    [self addObject:obj];
}

@end


@interface RispContext () <NSCopying>
@property (nonatomic, strong, readonly) RispLexicalScope *currentScope;
@property (nonatomic, strong, readonly) RispLexicalScope *specials;
@property (nonatomic, strong, readonly) RispLexicalScope *macros;
@property (nonatomic, strong, readonly) RispLexicalScope *keywords;

@property (nonatomic, assign, readonly, getter = isDeepCopyFromMainContext) BOOL deepCopyFromMainContext;
@end

@interface RispContext (InitSpecials)
+ (void)_initSpecials:(RispLexicalScope *)specials;
@end

@implementation RispContext

+ (void)load {
    
}

+ (instancetype)mainContext {
    return [[NSThread mainThread] threadContext];
}

+ (instancetype)defaultContext {
    return [self currentContext];
}

+ (instancetype)currentContext {
    RispContext *threadContext = [NSThread currentContext];
    if (!threadContext) {
        RispContext *context = [[RispContext alloc] init];;
        [[NSThread currentThread] setThreadContext:context];
        if (![NSThread isMainThread]) {
            [[RispContext mainContext] mutableCopy];
        }
        return context;
    }
    return threadContext;
}

+ (void)setCurrentContext:(RispContext *)context {
    [[NSThread currentThread] setThreadContext:context];
}

- (id)init  {
    if (self = [super init]) {
        _currentScope = [[RispRuntime baseEnvironment] rootScope];
        _specials = [[RispLexicalScope alloc] init];
        _keywords = [[RispLexicalScope alloc] init];
        [RispContext _initSpecials:_specials];
    }
    return self;
}

- (BOOL)isSpecial:(id)key {
    return _specials[key] != nil;
}

- (id)specialForKey:(id)key {
    return _specials[key];
}

- (void)registerSpecialValue:(id)value forKey:(id)key {
    _specials[key] =value;
}

- (id)isMacro:(id)key {
    if  ([key isKindOfClass:[RispSymbol class]] && _macros[key] == nil) {
        return nil;
    }
    return _macros[key];
}

- (RispKeywordExpression *)registerKeyword:(RispKeyword *)value {
    RispKeywordExpression *keyExpression = [[RispKeywordExpression alloc] initWithValue:value];
    _keywords[value] = keyExpression;
    return keyExpression;
}

- (BOOL)keywordIsRegisted:(RispKeyword *)keyword {
    return _keywords[keyword] != nil;
}

- (RispKeywordExpression *)keywordExpressionForKeyword:(RispKeyword *)value {
    return _keywords[value];
}

- (void)registerValue:(id)value forKey:(id)key {
    _currentScope[key] = value;
}

- (id)pushScope {
    RispLexicalScope *scope = [[RispLexicalScope alloc] initWithParent:_currentScope];
    _currentScope = scope;
    return _currentScope;
}

- (id)pushScope:(RispLexicalScope *)scope {
    return [self pushScopeWithConfiguration:[scope scope]];
}

- (id)pushScopeWithConfiguration:(NSDictionary *)info {
    RispLexicalScope *scope = [[RispLexicalScope alloc] initWithParent:_currentScope];
    [info enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        scope[key] = obj;
    }];
    _currentScope = scope;
    return _currentScope;
}

- (RispLexicalScope *)mergeScope:(RispLexicalScope *)scope {
    if (scope == nil || ([[scope scope] count] == 0 && [scope outer] == nil))
        return _currentScope;
    RispLexicalScope *new = [[RispLexicalScope alloc] initWithParent:_currentScope];
    
    NSMutableDictionary *env = [[NSMutableDictionary alloc] init];
    __block __weak void (^unsafe_lambda)(RispLexicalScope *scope);
    void (^lambda)(RispLexicalScope *s) = ^(RispLexicalScope *s) {
        if ([s depth] == 0) return ;
        [[s scope] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (env[key]) {
                return ;
            }
            env[key] = obj;
        }];
        if ([s outer]) {
            unsafe_lambda([s outer]);
        }
    };
    unsafe_lambda = lambda;
    lambda(scope);
    
    new = [[RispLexicalScope alloc] init];
    [new setScope:env];
    [new setDepth:[scope depth]];
    return new;
}

+ (NSDictionary *)mergeScope:(RispLexicalScope *)scope withScope:(RispLexicalScope *)other {
    if ((scope == nil || ([[scope scope] count] == 0 && [scope outer] == nil)) && (other == nil || ([[other scope] count] == 0 && [other outer] == nil)))
        return nil;
    
    __block __weak void (^unsafe_lambda)(NSMutableDictionary *set, RispLexicalScope *scope, BOOL checkRoot);
    void (^lambda)(NSMutableDictionary *set, RispLexicalScope *s, BOOL checkRoot) = ^(NSMutableDictionary *set, RispLexicalScope *s, BOOL checkRoot) {
        if (checkRoot && [s depth] == 0) return ;
        [[s scope] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (set[key]) {
                return ;
            }
            set[key] = obj;
        }];
        if ([s outer]) {
            unsafe_lambda(set, [s outer], checkRoot);
        }
    };
    unsafe_lambda = lambda;
    
    NSMutableDictionary *envScope = [[NSMutableDictionary alloc] init];
    lambda(envScope, scope, YES);
    
    NSMutableDictionary *envOther = [[NSMutableDictionary alloc] init];
    lambda(envOther, other, NO);
    
    [envOther addEntriesFromDictionary:envScope];
    if ([envOther count])
        return envOther;
    return nil;
}

- (id)pushScopeWithMergeScope:(RispLexicalScope *)scope {
    if (scope == nil || ([[scope scope] count] == 0 && [scope outer] == nil))
        return _currentScope;
    _currentScope = [self mergeScope:scope];
    return _currentScope;
}

- (void)popScope {
    if ([_currentScope depth] == 0)
        return;
    _currentScope = [_currentScope outer];
}

- (id)copyWithZone:(NSZone *)zone {
    RispContext *copy = [[RispContext alloc] init];
    RispContext *mainContext = [RispContext mainContext];
    
    copy->_deepCopyFromMainContext = YES;
    copy->_currentScope = [[mainContext currentScope] mutableCopy];
    copy->_keywords = [[mainContext keywords] mutableCopy];
    copy->_macros = [[mainContext macros] mutableCopy];
    copy->_specials = [[mainContext specials] mutableCopy];
    copy->_status = [mainContext status];
    return copy;
}

- (id)mutableCopy {
    return [self copy];
}
@end

@implementation RispContext (InitSpecials)

+ (void)_initSpecials:(RispLexicalScope *)specials {
    specials[[RispDotExpression speicalKey]] = [RispDotExpression class];
    specials[[RispDefExpression speicalKey]] = [RispDefExpression class];
    specials[[RispDefnExpression speicalKey]] = [RispDefnExpression class];
    specials[[RispIfExpression speicalKey]] = [RispIfExpression class];
    specials[[RispLetExpression speicalKey]] = [RispLetExpression class];
    specials[[RispSymbol QUOTE]] = [RispConstantExpression class];
}

@end

@implementation NSThread (RispContext)

+ (RispContext *)currentContext {
    return [[NSThread currentThread] threadContext];
}

+ (RispContext *)mainContext {
    return [[NSThread mainThread] threadContext];
}

- (RispContext *)threadContext {
    id context = [self threadDictionary][NSStringFromClass([RispContext class])];
    return context;
}

- (void)setThreadContext:(RispContext *)context {
    [self threadDictionary][NSStringFromClass([RispContext class])] = context;
}

@end