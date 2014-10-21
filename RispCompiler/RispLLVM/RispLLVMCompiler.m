//
//  RispLLVMCompiler.m
//  RispCompiler
//
//  Created by closure on 9/3/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispLLVMCompiler.h"
#import <RispCompiler/RispASTContext.h>
#import <RispCompiler/RispASTContextRecursiveVisitor.h>

@implementation RispLLVMCompiler
+ (NSArray *)compileFiles:(NSArray *)inputFiles outputDirectory:(NSString *)outputDirectory options:(RispASTContextDoneOptions)options {
    if (inputFiles == nil || [inputFiles count] == 0 || outputDirectory == nil) {
        return nil;
    }
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (NSString *filePath in inputFiles) {
        @autoreleasepool {
            NSString *fullPath = [filePath stringByStandardizingPath];
            NSString *fileName = fullPath;
            NSString *code = [[NSString alloc] initWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
            fileName = [[fileName lastPathComponent] stringByDeletingPathExtension];
            printf("compiling %s...", [fullPath UTF8String]);
            RispASTContext *ASTContext = [[RispASTContext alloc] initWithName:[fileName stringByDeletingPathExtension]];
            NSArray *exprs = [RispASTContext expressionFromCurrentLine:code];
            for (id <RispExpression> expr in exprs) {
                RispAbstractSyntaxTree *AST = [[RispAbstractSyntaxTree alloc] initWithExpression:expr];
//                NSLog(@"%@", AST);
//                [[[RispASTContextRecursiveVisitor alloc] initWithAbstractSyntaxTree:AST] visit:^(RispBaseExpression *expr, NSUInteger level) {
//                    NSMutableString *desc = [[NSMutableString alloc] init];
//                    for (NSUInteger idx = 1; idx < level; idx++) {
//                        [desc appendString:@"  "];
//                    }
//                    [desc appendString:[[expr class] description]];
//                    NSLog(@"%@", desc);
//                } level:0];
                [ASTContext emitRispAST:AST];
            }
            [ASTContext doneWithOutputPath:outputDirectory options:options];
            printf("done!\n");
            [results addObject:[NSString stringWithFormat:@"%@/%@.o", outputDirectory, fileName]];
        }
    }
    return results;
}
@end
