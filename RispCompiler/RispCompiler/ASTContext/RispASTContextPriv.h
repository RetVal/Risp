//
//  RispASTContextPriv.h
//  RispCompiler
//
//  Created by closure on 9/19/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef RispCompiler_RispASTContextPriv_h
#define RispCompiler_RispASTContextPriv_h

namespace RispLLVM {
    class RispLLVMFunctionMeta;
    class RispClosureMeta;
}

@interface RispASTContext (Priv)
- (RispLLVM::RispLLVMFunctionMeta *)metaForFunction:(llvm::Function *)function;
- (BOOL)_isClosure:(llvm::Function *)function;
- (void)_addClosure:(llvm::Function *)function;
- (RispLLVM::RispClosureMeta)_closureMetaForFunction:(llvm::Function *)function;
@end

#endif
