//
//  RispASTContext.h
//  RispCompiler
//
//  Created by closure on 8/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/Risp.h>
#import <RispCompiler/RispASTContextDoneOptions.h>

@class RispScopeStack;

typedef NS_ENUM(NSUInteger, RispScopeStackPushType) {
    RispScopeStackPushFunction = 0,
    RispScopeStackPushIfBlock = 1,
    RispScopeStackPushLetBlock = 2,
};

@interface RispASTContext : NSObject
@property (nonatomic, strong, readonly) id CGM;
@property (atomic   , assign, readonly) NSUInteger anonymousFunctionCounter;
@property (nonatomic, strong, readonly) NSString *asmFilePath;
@property (nonatomic, strong, readonly) NSString *objectFilePath;
@property (nonatomic, strong, readonly) NSString *llvmirFilePath;

// status for symbol lookup
@property (nonatomic, assign, getter=isVisiting) BOOL visiting;
@property (nonatomic, assign, getter=isLastSymbolInScope) BOOL lastSymbolInScope;


+ (instancetype)ASTContext;
- (instancetype)initWithName:(NSString *)name;
+ (NSArray *)expressionFromCurrentLine:(NSString *)sender;
- (void)emitRispAST:(RispAbstractSyntaxTree *)ast;
- (BOOL)doneWithOutputPath:(NSString *)path options:(RispASTContextDoneOptions)options;

- (RispScopeStack *)currentStack;
- (RispScopeStack *)pushStackWithType:(RispScopeStackPushType)pushType;
- (void)popStack;

- (NSUInteger)currentAnonymousFunctionCounter;
@end
