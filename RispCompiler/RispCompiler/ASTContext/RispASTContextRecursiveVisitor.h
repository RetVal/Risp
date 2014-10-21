//
//  RispASTContextRecursiveVisitor.h
//  RispCompiler
//
//  Created by closure on 9/3/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RispAbstractSyntaxTree, RispBaseExpression;

@interface RispASTContextRecursiveVisitor : NSObject
- (instancetype)initWithAbstractSyntaxTree:(RispAbstractSyntaxTree *)ast;
- (BOOL)visit:(BOOL(^)(RispBaseExpression *expr, NSUInteger level))process level:(NSUInteger)level;
@end
