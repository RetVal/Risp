//
//  RispContext.h
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispLexicalScope.h>
#import <Risp/RispSymbol.h>
#import <Risp/RispList.h>
#import <Risp/RispVector.h>
#import <Risp/NSObject+RispMeta.h>
#import <Risp/RispKeyword.h>
#import <Risp/RispRuntime.h>
#import <Risp/RispKeywordExpression.h>

typedef NS_ENUM(NSUInteger, RispContextStatus) {
    RispContextStatement = 0,       // do not require value
    RispContextExpression = 1,      // require value
    RispContextClosure = 2,         // local binding
    RispContextEval = 3,            // eval the expression
};

@interface RispContext : NSObject
+ (instancetype)mainContext;
+ (instancetype)defaultContext;
+ (instancetype)currentContext;
+ (void)setCurrentContext:(RispContext *)context;

+ (NSDictionary *)mergeScope:(RispLexicalScope *)scope withScope:(RispLexicalScope *)other;

@property (nonatomic, assign) RispContextStatus status;

- (RispLexicalScope *)currentScope;
- (void)registerValue:(id)value forKey:(id)key;

// special form api group
- (BOOL)isSpecial:(id)key;
- (id)specialForKey:(id)key;
- (void)registerSpecialValue:(id)value forKey:(id)key;

// keyword set
- (RispKeywordExpression *)registerKeyword:(RispKeyword *)value;
- (BOOL)keywordIsRegisted:(RispKeyword *)keyword;
- (RispKeywordExpression *)keywordExpressionForKeyword:(RispKeyword *)value;

- (id)isMacro:(id)key;

- (RispLexicalScope *)mergeScope:(RispLexicalScope *)scope;

- (id)pushScope;
- (id)pushScope:(RispLexicalScope *)scope;
- (id)pushScopeWithConfiguration:(NSDictionary *)info;
- (id)pushScopeWithMergeScope:(RispLexicalScope *)scope;
- (void)popScope;

@end
