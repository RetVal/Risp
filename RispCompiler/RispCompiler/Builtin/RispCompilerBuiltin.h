//
//  RispCompilerBuiltin.h
//  RispCompiler
//
//  Created by closure on 9/3/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef __RISPCOMPILER_BUILTIN__
#define __RISPCOMPILER_BUILTIN__
#import <Foundation/Foundation.h>
#include "llvm/IR/Function.h"
@class RispASTContext;
@interface RispCompilerBuiltin : NSObject
+ (llvm::Function *)list:(RispASTContext *)ast;
@end
#endif