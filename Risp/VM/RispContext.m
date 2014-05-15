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

@interface NSThread (RispContext)
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


@interface RispContext ()
@property (nonatomic, strong, readonly) RispLexicalScope *currentScope;
@property (nonatomic, strong, readonly) RispLexicalScope *specials;
@property (nonatomic, strong, readonly) RispLexicalScope *macros;
@property (nonatomic, strong, readonly) RispLexicalScope *keywords;
@end

@interface RispContext (InitSpecials)
+ (void)_initSpecials:(RispLexicalScope *)specials;
@end

@implementation RispContext

+ (void)load {
    
}

+ (instancetype)defaultContext {
    return [self currentContext];
}

+ (instancetype)currentContext {
    if (![NSThread currentContext]) {
        RispContext *context = [[RispContext alloc] init];
        [[NSThread currentThread] setThreadContext:context];
        return context;
    }
    return [NSThread currentContext];
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

- (id)pushScopeWithConfiguration:(NSDictionary *)info {
    RispLexicalScope *scope = [[RispLexicalScope alloc] initWithParent:_currentScope];
    [info enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        scope[key] = obj;
    }];
    _currentScope = scope;
    return _currentScope;
}

- (void)popScope {
    _currentScope = [_currentScope outer];
}
@end

@implementation RispContext (InitSpecials)

+ (void)_initSpecials:(RispLexicalScope *)specials {
    specials[[RispDotExpression speicalKey]] = [RispDotExpression class];
    specials[[RispDefExpression speicalKey]] = [RispDefExpression class];
    specials[[RispDefnExpression speicalKey]] = [RispDefnExpression class];
    specials[[RispIfExpression speicalKey]] = [RispIfExpression class];
    specials[[RispSymbol QUOTE]] = [RispConstantExpression class];
}

@end

@implementation NSThread (RispContext)

+ (RispContext *)currentContext {
    return [[NSThread currentThread] threadContext];
}

- (RispContext *)threadContext {
    id context = [self threadDictionary][NSStringFromClass([RispContext class])];
    return context;
}

- (void)setThreadContext:(RispContext *)context {
    [self threadDictionary][NSStringFromClass([RispContext class])] = context;
}

@end