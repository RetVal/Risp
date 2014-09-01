//
//  RispASTContext.h
//  RispCompiler
//
//  Created by closure on 8/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/Risp.h>

@class RispScopeStack;

@interface RispASTContext : NSObject
@property (nonatomic, strong, readonly) id CGM;
@property (atomic   , assign, readonly) NSUInteger anonymousFunctionCounter;
@property (nonatomic, strong, readonly) NSString *asmFilePath;
@property (nonatomic, strong, readonly) NSString *objectFilePath;
@property (nonatomic, strong, readonly) NSString *llvmirFilePath;
+ (instancetype)ASTContext;
- (instancetype)initWithName:(NSString *)name;
+ (NSArray *)expressionFromCurrentLine:(NSString *)sender;
- (void)emitRispAST:(RispAbstractSyntaxTree *)ast;
- (void)doneWithOutputPath:(NSString *)path;

- (RispScopeStack *)currentStack;
- (RispScopeStack *)pushStack;
- (void)popStack;
@end
