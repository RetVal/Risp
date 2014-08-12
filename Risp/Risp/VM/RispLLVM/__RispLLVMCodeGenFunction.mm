//
//  __RispLLVMCodeGenFunction.m
//  Risp
//
//  Created by closure on 8/9/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "__RispLLVMCodeGenFunction.h"

@implementation __RispLLVMCodeGenFunction
+ (llvm::Constant *)castFunctionType:(llvm::Constant *)function arguments:(llvm::ArrayRef<llvm::Value *>)args {
    if (!function) return nil;
    
    llvm::Function *func = llvm::cast<llvm::Function>(function);
    llvm::FunctionType *fty = func->getFunctionType();
    
    llvm::SmallVector<llvm::Type *, 5>argsTypes;
    for (unsigned i = 0; i < fty->getNumParams(); i++) {
        argsTypes.push_back(fty->getParamType(i));
    }
    
    for (unsigned i = fty->getNumParams(); i < args.size(); i++) {
        argsTypes.push_back(args[i]->getType());
    }
    fty = llvm::FunctionType::get(fty->getReturnType(), argsTypes, NO);
    return llvm::ConstantExpr::getBitCast(function, fty->getPointerTo());
}

+ (void)setNamesForFunction:(llvm::Function *)function arugmentNames:(llvm::ArrayRef<llvm::StringRef>)argNames {
    if (!function) return;
    assert(function->getFunctionType()->getNumParams() == argNames.size() &&
           "The number of function arguments and names should be equal to.");
    unsigned i = 0;
    for (auto &arg : function->args()) {
        arg.setName(argNames[i++]);
    }
}
@end
