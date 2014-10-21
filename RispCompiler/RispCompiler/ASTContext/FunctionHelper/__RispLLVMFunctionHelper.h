//
//  __RispLLVMFunctionHelper.h
//  RispCompiler
//
//  Created by closure on 8/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispVector.h>
#include "llvm/IR/Value.h"
#include "llvm/ADT/SmallVector.h"
#import <Risp/RispMethodExpression.h>
//class llvm::Function;

@class RispASTContext, RispNameMangling;
/** __RispLLVMFunctionHelper
 ** a small helper class for find a function by a function name(demangling)
 */
@interface __RispLLVMFunctionHelper : NSObject
+ (void)__argumentsBindingToFunction:(llvm::Value *)vec args:(RispVector *)args function:(llvm::Function *)function binding:(llvm::SmallVector<llvm::Value *, 8> &)binding isVariadic:(BOOL)isVariadic context:(RispASTContext *)context;

+ (llvm::Function *)__functionWithMangling:(RispNameMangling *)mangling fromName:(NSString *)funcName method:(RispMethodExpression *)method arguments:(RispVector *)arguments context:(RispASTContext *)context;
@end
