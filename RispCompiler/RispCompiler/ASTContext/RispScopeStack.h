//
//  RispScopeStack.h
//  RispCompiler
//
//  Created by closure on 8/21/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <llvm/ADT/DenseMap.h>
#include <llvm/IR/Value.h>
#import <Risp/RispSymbolExpression.h>
#include "RispLLVMValueMeta.h"
#import <RispCompiler/RispASTContext.h>

@interface RispScopeStack : NSObject <NSCopying>
@property (strong, nonatomic, readonly) RispScopeStack *inner;
@property (strong, nonatomic, readonly) NSException *exception;
@property (assign, nonatomic, readonly) NSUInteger depth;
@property (assign, nonatomic) RispScopeStackPushType pushType;
//@property (strong, nonatomic) NSDictionary *scope;

- (id)init;
- (id)initWithParent:(RispScopeStack *)outer;
- (id)initWithParent:(RispScopeStack *)outer child:(RispScopeStack *)inner;

- (RispScopeStack *)outer;

- (NSArray *)keys;
- (NSArray *)values;

- (llvm::Value *)objectForKey:(RispSymbolExpression *)aKey;
- (llvm::Value *)objectForKey:(RispSymbolExpression *)aKey atDepth:(NSUInteger *)depth;
- (void)setObject:(llvm::Value *)object forKey:(RispSymbolExpression *)aKey;

- (RispLLVM::RispLLVMValueMeta)metaForValue:(llvm::Value *)aValue;
- (void)setMeta:(RispLLVM::RispLLVMValueMeta)meta forValue:(llvm::Value *)aValue;

- (llvm::Value *)objectForKeyedSubscript:(RispSymbolExpression *)key;
- (void)setObject:(llvm::Value *)obj forKeyedSubscript:(RispSymbolExpression *)key;

- (BOOL)isCurrentScope:(NSUInteger)depth;
@end
