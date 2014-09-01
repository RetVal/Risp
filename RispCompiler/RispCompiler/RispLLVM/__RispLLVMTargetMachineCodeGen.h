//
//  __RispLLVMTargetMachineCodeGen.h
//  Risp
//
//  Created by closure on 8/9/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef __Risp____RispLLVMTargetMachineCodeGen__
#define __Risp____RispLLVMTargetMachineCodeGen__
#import <Foundation/Foundation.h>
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/ADT/Triple.h"

namespace RispLLVM {
    typedef enum RispTargetMachineCodeGenOutputFileType {
        AssemblyFile = 0,
        ObjectFile,
        Null
    }RispTargetMachineCodeGenOutputFileType;
}

@interface __RispLLVMTargetMachineCodeGen : NSObject
+ (NSUInteger)compileASMModule:(llvm::Module *)module context:(llvm::LLVMContext &)context output:(std::string &)output;

+ (NSUInteger)compileObjectModule:(llvm::Module *)module context:(llvm::LLVMContext &)context outputPath:(NSString *)outputPath;

+ (NSInteger)compileModule:(llvm::Module *)module context:(llvm::LLVMContext &)context targetNamed:(std::string)march targetTriple:(std::string)targetTriple optLevel:(NSUInteger)level isNoIntegratedAssembler:(BOOL)noIntegratedAssembler isEnableDwarfDirectory:(BOOL)enableDwarfDirectory isGenerateSoftFloatCalls:(BOOL)generateSoftFloatCalls isDisableSimplifyLibCalls:(BOOL)disableSimplifyLibCalls isRelaxAll:(BOOL)relaxAll noVerify:(BOOL)noVerify fileType:(RispLLVM::RispTargetMachineCodeGenOutputFileType)fileType startAfter:(std::string)startAfter stopAfter:(std::string)stopAfter outputStream:(llvm::raw_ostream&)outputStream ;

@end
#endif /* defined(__Risp____RispLLVMTargetMachineCodeGen__) */
