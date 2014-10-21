//
//  RispCompilerBuiltin.m
//  RispCompiler
//
//  Created by closure on 9/3/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispCompilerBuiltin.h"
#import "__RispLLVMFoundation+Context.h"
#import "__RispLLVMFoundation.h"
#import "RispASTContext.h"
#import "RispNameMangling.h"
#import "RispNameManglingFunctionDescriptor.h"
#import "RispNameManglingArgumentsDescriptor.h"

@implementation RispCompilerBuiltin
+ (llvm::Function *)list:(RispASTContext *)ast {
    __RispLLVMFoundation *CGM = [ast CGM];
    RispFnExpression *fnExpr = [RispList creator];
    NSArray *functionDescriptors = [[RispNameMangling nameMangling] functionMangling:fnExpr];
    if (functionDescriptors && [functionDescriptors count]) {
        [ast emitRispAST:[[RispAbstractSyntaxTree alloc] initWithExpression:fnExpr]];
    }
    return [CGM module]->getFunctionList().end();
}
@end
