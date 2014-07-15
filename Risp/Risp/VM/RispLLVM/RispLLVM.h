//
//  RispLLVM.h
//  Risp
//
//  Created by closure on 6/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef Risp_RispLLVM_h
#define Risp_RispLLVM_h

// Copyright 2013 The Rust Project Developers. See the COPYRIGHT
// file at the top-level directory of this distribution and at
// http://rust-lang.org/COPYRIGHT.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#if TARGET_OS_MAC
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InlineAsm.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/PassManager.h"
#include "llvm/IR/InlineAsm.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/Analysis/Passes.h"
#include "llvm/Analysis/Lint.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/Triple.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/Timer.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/DynamicLibrary.h"
#include "llvm/Support/Memory.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/JIT.h"
#include "llvm/ExecutionEngine/JITMemoryManager.h"
#include "llvm/ExecutionEngine/MCJIT.h"
#include "llvm/ExecutionEngine/Interpreter.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/Instrumentation.h"
#include "llvm/Transforms/Vectorize.h"
#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm-c/Core.h"
#include "llvm-c/BitReader.h"
#include "llvm-c/ExecutionEngine.h"
#include "llvm-c/Object.h"

#if LLVM_VERSION_MINOR >= 5
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/DIBuilder.h"
#include "llvm/Linker/Linker.h"
#else
#include "llvm/Assembly/PrintModulePass.h"
#include "llvm/DebugInfo.h"
#include "llvm/DIBuilder.h"
#include "llvm/Linker.h"
#endif

// Used by RustMCJITMemoryManager::getPointerToNamedFunction()
// to get around glibc issues. See the function for more information.
#ifdef __linux__
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#endif

#include "llvm/Object/Archive.h"
#include "llvm/Object/ObjectFile.h"

#if LLVM_VERSION_MINOR >= 5
#include "llvm/IR/CallSite.h"
#else
#include "llvm/Support/CallSite.h"
#endif

using namespace llvm;
using namespace llvm::sys;
using namespace llvm::object;

typedef DIBuilder* DIBuilderRef;

extern "C" {
    void RispLLVMSetLastError(const char * err);
    LLVMMemoryBufferRef RispLLVMCreateMemoryBufferWithContentsOfFile(const char * Path);
    char * RispLLVMGetLastError();
    void RispLLVMSetNormalizedTarget(LLVMModuleRef M, const char * triple);
    LLVMValueRef RispLLVMConstSmallInt(LLVMTypeRef IntTy, unsigned int N, LLVMBool SignExtend);
    LLVMValueRef RispLLVMConstInt(LLVMTypeRef IntTy, unsigned int N_hi, unsigned int N_lo, LLVMBool SignExtend);
    void RispLLVMPrintPassTimings();
    LLVMValueRef RispLLVMGetOrInsertFunction(LLVMModuleRef M, const char * Name, LLVMTypeRef FunctionTy);
    LLVMTypeRef RispLLVMMetadataTypeInContext(LLVMContextRef C);
    void RispLLVMAddCallSiteAttribute(LLVMValueRef Instr, unsigned int index, uint64_t Val);
    void RispLLVMAddFunctionAttribute(LLVMValueRef Fn, unsigned int index, uint64_t Val);
    void RispLLVMAddFunctionAttrString(LLVMValueRef Fn, unsigned int index, const char * Name);
    void RispLLVMRemoveFunctionAttrString(LLVMValueRef fn, unsigned int index, const char * Name);
    LLVMValueRef RispLLVMBuildAtomicLoad(LLVMBuilderRef B, LLVMValueRef source, const char * Name, enum llvm::AtomicOrdering order, unsigned int alignment);
    LLVMValueRef RispLLVMBuildAtomicStore(LLVMBuilderRef B, LLVMValueRef val, LLVMValueRef target, enum llvm::AtomicOrdering order, unsigned int alignment);
    LLVMValueRef RispLLVMBuildAtomicCmpXchg(LLVMBuilderRef B, LLVMValueRef target, LLVMValueRef old, LLVMValueRef source, enum llvm::AtomicOrdering order, enum llvm::AtomicOrdering failure_order);
    LLVMValueRef RispLLVMBuildAtomicFence(LLVMBuilderRef B, enum llvm::AtomicOrdering order);
    LLVMValueRef RispLLVMInlineAsm(LLVMTypeRef Ty, char * AsmString, char * Constraints, LLVMBool HasSideEffects, LLVMBool IsAlignStack, unsigned int Dialect);
    void RispLLVMAddModuleFlag(LLVMModuleRef M, const char * name, uint32_t value);
    DIBuilderRef RispLLVMDIBuilderCreate(LLVMModuleRef M);
    void RispLLVMDIBuilderDispose(DIBuilderRef Builder);
    void RispLLVMDIBuilderFinalize(DIBuilderRef Builder);
    void RispLLVMDIBuilderCreateCompileUnit(DIBuilderRef Builder, unsigned int Lang, const char * File, const char * Dir, const char * Producer, bool isOptimized, const char * Flags, unsigned int RuntimeVer, const char * SplitName);
    LLVMValueRef RispLLVMDIBuilderCreateFile(DIBuilderRef Builder, const char * Filename, const char * Directory);
    LLVMValueRef RispLLVMDIBuilderCreateSubroutineType(DIBuilderRef Builder, LLVMValueRef File, LLVMValueRef ParameterTypes);
    LLVMValueRef RispLLVMDIBuilderCreateFunction(DIBuilderRef Builder, LLVMValueRef Scope, const char * Name, const char * LinkageName, LLVMValueRef File, unsigned int LineNo, LLVMValueRef Ty, bool isLocalToUnit, bool isDefinition, unsigned int ScopeLine, unsigned int Flags, bool isOptimized, LLVMValueRef Fn, LLVMValueRef TParam, LLVMValueRef Decl);
    LLVMValueRef RispLLVMDIBuilderCreateBasicType(DIBuilderRef Builder, const char * Name, uint64_t SizeInBits, uint64_t AlignInBits, unsigned int Encoding);
    LLVMValueRef RispLLVMDIBuilderCreatePointerType(DIBuilderRef Builder, LLVMValueRef PointeeTy, uint64_t SizeInBits, uint64_t AlignInBits, const char * Name);
    LLVMValueRef RispLLVMDIBuilderCreateStructType(DIBuilderRef Builder, LLVMValueRef Scope, const char * Name, LLVMValueRef File, unsigned int LineNumber, uint64_t SizeInBits, uint64_t AlignInBits, unsigned int Flags, LLVMValueRef DerivedFrom, LLVMValueRef Elements, unsigned int RunTimeLang, LLVMValueRef VTableHolder, const char * UniqueId);
    LLVMValueRef RispLLVMDIBuilderCreateMemberType(DIBuilderRef Builder, LLVMValueRef Scope, const char * Name, LLVMValueRef File, unsigned int LineNo, uint64_t SizeInBits, uint64_t AlignInBits, uint64_t OffsetInBits, unsigned int Flags, LLVMValueRef Ty);
    LLVMValueRef RispLLVMDIBuilderCreateLexicalBlock(DIBuilderRef Builder, LLVMValueRef Scope, LLVMValueRef File, unsigned int Line, unsigned int Col, unsigned int Discriminator);
    LLVMValueRef RispLLVMDIBuilderCreateStaticVariable(DIBuilderRef Builder, LLVMValueRef Context, const char * Name, const char * LinkageName, LLVMValueRef File, unsigned int LineNo, LLVMValueRef Ty, bool isLocalToUnit, LLVMValueRef Val, LLVMValueRef Decl);
    LLVMValueRef RispLLVMDIBuilderCreateLocalVariable(DIBuilderRef Builder, unsigned int Tag, LLVMValueRef Scope, const char * Name, LLVMValueRef File, unsigned int LineNo, LLVMValueRef Ty, bool AlwaysPreserve, unsigned int Flags, unsigned int ArgNo);
    LLVMValueRef RispLLVMDIBuilderCreateArrayType(DIBuilderRef Builder, uint64_t Size, uint64_t AlignInBits, LLVMValueRef Ty, LLVMValueRef Subscripts);
    LLVMValueRef RispLLVMDIBuilderCreateVectorType(DIBuilderRef Builder, uint64_t Size, uint64_t AlignInBits, LLVMValueRef Ty, LLVMValueRef Subscripts);
    LLVMValueRef RispLLVMDIBuilderGetOrCreateSubrange(DIBuilderRef Builder, int64_t Lo, int64_t Count);
    LLVMValueRef RispLLVMDIBuilderGetOrCreateArray(DIBuilderRef Builder, LLVMValueRef * Ptr, unsigned int Count);
    LLVMValueRef RispLLVMDIBuilderInsertDeclareAtEnd(DIBuilderRef Builder, LLVMValueRef Val, LLVMValueRef VarInfo, LLVMBasicBlockRef InsertAtEnd);
    LLVMValueRef RispLLVMDIBuilderInsertDeclareBefore(DIBuilderRef Builder, LLVMValueRef Val, LLVMValueRef VarInfo, LLVMValueRef InsertBefore);
    LLVMValueRef RispLLVMDIBuilderCreateEnumerator(DIBuilderRef Builder, const char * Name, uint64_t Val);
    LLVMValueRef RispLLVMDIBuilderCreateEnumerationType(DIBuilderRef Builder, LLVMValueRef Scope, const char * Name, LLVMValueRef File, unsigned int LineNumber, uint64_t SizeInBits, uint64_t AlignInBits, LLVMValueRef Elements, LLVMValueRef ClassType);
    LLVMValueRef RispLLVMDIBuilderCreateUnionType(DIBuilderRef Builder, LLVMValueRef Scope, const char * Name, LLVMValueRef File, unsigned int LineNumber, uint64_t SizeInBits, uint64_t AlignInBits, unsigned int Flags, LLVMValueRef Elements, unsigned int RunTimeLang, const char * UniqueId);
    LLVMValueRef RispLLVMDIBuilderCreateTemplateTypeParameter(DIBuilderRef Builder, LLVMValueRef Scope, const char * Name, LLVMValueRef Ty, LLVMValueRef File, unsigned int LineNo, unsigned int ColumnNo);
    LLVMValueRef RispLLVMDIBuilderCreateOpDeref(LLVMTypeRef IntTy);
    LLVMValueRef RispLLVMDIBuilderCreateOpPlus(LLVMTypeRef IntTy);
    LLVMValueRef RispLLVMDIBuilderCreateComplexVariable(DIBuilderRef Builder, unsigned int Tag, LLVMValueRef Scope, const char * Name, LLVMValueRef File, unsigned int LineNo, LLVMValueRef Ty, LLVMValueRef * AddrOps, unsigned int AddrOpsCount, unsigned int ArgNo);
    LLVMValueRef RispLLVMDIBuilderCreateNameSpace(DIBuilderRef Builder, LLVMValueRef Scope, const char * Name, LLVMValueRef File, unsigned int LineNo);
    void RispLLVMDICompositeTypeSetTypeArray(LLVMValueRef CompositeType, LLVMValueRef TypeArray);
    char * RispLLVMTypeToString(LLVMTypeRef Type);
    bool RispLLVMLinkInExternalBitcode(LLVMModuleRef dst, char * bc, size_t len);
    void * RispLLVMOpenArchive(char * path);
    const char * RispLLVMArchiveReadSection(class llvm::object::Archive * ar, char * name, size_t * size);
    void RispLLVMDestroyArchive(class llvm::object::Archive * ar);
    void RispLLVMSetDLLExportStorageClass(LLVMValueRef Value);
    int RispLLVMVersionMinor();
    int RispLLVMVersionMajor();
    int RispLLVMGetSectionName(LLVMSectionIteratorRef SI, const char ** ptr);
    LLVMTypeRef RispLLVMArrayType(LLVMTypeRef ElementType, uint64_t ElementCount);
}
#endif
#endif