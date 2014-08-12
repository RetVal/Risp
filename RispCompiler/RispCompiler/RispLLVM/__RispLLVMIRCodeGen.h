//
//  __RispLLVMIRCodeGen.h
//  Risp
//
//  Created by closure on 8/9/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"

@interface __RispLLVMIRCodeGen : NSObject
+ (NSString *)IRCodeFromModule:(llvm::Module *)module;
@end
