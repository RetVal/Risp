//
//  RispASTContext.h
//  RispCompiler
//
//  Created by closure on 8/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/Risp.h>

@interface RispASTContext : NSObject
+ (instancetype)ASTContext;
+ (NSArray *)expressionFromCurrentLine:(NSString *)sender;
@property (nonatomic, strong, readonly) id CGM;
- (void)emitRispAST:(RispAbstractSyntaxTree *)ast;

- (void)done;
@end
