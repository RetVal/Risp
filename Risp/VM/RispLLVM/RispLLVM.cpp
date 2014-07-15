//
//  RispLLVM.cpp
//  Risp
//
//  Created by closure on 6/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

// Copyright 2013 The Rust Project Developers. See the COPYRIGHT
// file at the top-level directory of this distribution and at
// http://rust-lang.org/COPYRIGHT.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#include "RispLLVM.h"

static char *LastError;

extern "C" void RispLLVMSetLastError(const char *err) {
    free((void*) LastError);
    LastError = strdup(err);
}

extern "C" LLVMMemoryBufferRef RispLLVMCreateMemoryBufferWithContentsOfFile(const char *Path) {
    LLVMMemoryBufferRef MemBuf = NULL;
    char *err = NULL;
    LLVMCreateMemoryBufferWithContentsOfFile(Path, &MemBuf, &err);
    if (err != NULL) {
        RispLLVMSetLastError(err);
    }
    return MemBuf;
}

extern "C" char *RispLLVMGetLastError(void) {
    char *ret = LastError;
    LastError = NULL;
    return ret;
}

extern "C" void RispLLVMSetNormalizedTarget(LLVMModuleRef M, const char *triple) {
    unwrap(M)->setTargetTriple(Triple::normalize(triple));
}

extern "C" LLVMValueRef RispLLVMConstSmallInt(LLVMTypeRef IntTy, unsigned N,
                                              LLVMBool SignExtend) {
    return LLVMConstInt(IntTy, (unsigned long long)N, SignExtend);
}

extern "C" LLVMValueRef RispLLVMConstInt(LLVMTypeRef IntTy,
                                         unsigned N_hi,
                                         unsigned N_lo,
                                         LLVMBool SignExtend) {
    unsigned long long N = N_hi;
    N <<= 32;
    N |= N_lo;
    return LLVMConstInt(IntTy, N, SignExtend);
}

extern "C" void RispLLVMPrintPassTimings() {
    raw_fd_ostream OS (2, false); // stderr.
    TimerGroup::printAll(OS);
}

extern "C" LLVMValueRef RispLLVMGetOrInsertFunction(LLVMModuleRef M,
                                                const char* Name,
                                                LLVMTypeRef FunctionTy) {
    return wrap(unwrap(M)->getOrInsertFunction(Name,
                                               unwrap<FunctionType>(FunctionTy)));
}

extern "C" LLVMTypeRef RispLLVMMetadataTypeInContext(LLVMContextRef C) {
    return wrap(Type::getMetadataTy(*unwrap(C)));
}

extern "C" void RispLLVMAddCallSiteAttribute(LLVMValueRef Instr, unsigned index, uint64_t Val) {
    CallSite Call = CallSite(unwrap<Instruction>(Instr));
    AttrBuilder B;
    B.addRawValue(Val);
    Call.setAttributes(
                       Call.getAttributes().addAttributes(Call->getContext(), index,
                                                          AttributeSet::get(Call->getContext(),
                                                                            index, B)));
}

extern "C" void RispLLVMAddFunctionAttribute(LLVMValueRef Fn, unsigned index, uint64_t Val) {
    Function *A = unwrap<Function>(Fn);
    AttrBuilder B;
    B.addRawValue(Val);
    A->addAttributes(index, AttributeSet::get(A->getContext(), index, B));
}

extern "C" void RispLLVMAddFunctionAttrString(LLVMValueRef Fn, unsigned index, const char *Name) {
    Function *F = unwrap<Function>(Fn);
    AttrBuilder B;
    B.addAttribute(Name);
    F->addAttributes(index, AttributeSet::get(F->getContext(), index, B));
}

extern "C" void RispLLVMRemoveFunctionAttrString(LLVMValueRef fn, unsigned index, const char *Name) {
    Function *f = unwrap<Function>(fn);
    LLVMContext &C = f->getContext();
    AttrBuilder B;
    B.addAttribute(Name);
    AttributeSet to_remove = AttributeSet::get(C, index, B);
    
    AttributeSet attrs = f->getAttributes();
    f->setAttributes(attrs.removeAttributes(f->getContext(),
                                            index,
                                            to_remove));
}

extern "C" LLVMValueRef RispLLVMBuildAtomicLoad(LLVMBuilderRef B,
                                            LLVMValueRef source,
                                            const char* Name,
                                            AtomicOrdering order,
                                            unsigned alignment) {
    LoadInst* li = new LoadInst(unwrap(source),0);
    li->setVolatile(true);
    li->setAtomic(order);
    li->setAlignment(alignment);
    return wrap(unwrap(B)->Insert(li, Name));
}

extern "C" LLVMValueRef RispLLVMBuildAtomicStore(LLVMBuilderRef B,
                                             LLVMValueRef val,
                                             LLVMValueRef target,
                                             AtomicOrdering order,
                                             unsigned alignment) {
    StoreInst* si = new StoreInst(unwrap(val),unwrap(target));
    si->setVolatile(true);
    si->setAtomic(order);
    si->setAlignment(alignment);
    return wrap(unwrap(B)->Insert(si));
}

extern "C" LLVMValueRef RispLLVMBuildAtomicCmpXchg(LLVMBuilderRef B,
                                               LLVMValueRef target,
                                               LLVMValueRef old,
                                               LLVMValueRef source,
                                               AtomicOrdering order,
                                               AtomicOrdering failure_order) {
    return wrap(unwrap(B)->CreateAtomicCmpXchg(unwrap(target), unwrap(old),
                                               unwrap(source), order
#if LLVM_VERSION_MINOR >= 5
                                               , failure_order
#endif
                                               ));
}
extern "C" LLVMValueRef RispLLVMBuildAtomicFence(LLVMBuilderRef B, AtomicOrdering order) {
    return wrap(unwrap(B)->CreateFence(order));
}

extern "C" void LLVMSetDebug(int Enabled) {
#ifndef NDEBUG
    DebugFlag = Enabled;
#endif
}

extern "C" LLVMValueRef RispLLVMInlineAsm(LLVMTypeRef Ty,
                                      char *AsmString,
                                      char *Constraints,
                                      LLVMBool HasSideEffects,
                                      LLVMBool IsAlignStack,
                                      unsigned Dialect) {
    return wrap(InlineAsm::get(unwrap<FunctionType>(Ty), AsmString,
                               Constraints, HasSideEffects,
                               IsAlignStack, (InlineAsm::AsmDialect) Dialect));
}

template<typename DIT>
DIT unwrapDI(LLVMValueRef ref) {
    return DIT(ref ? unwrap<MDNode>(ref) : NULL);
}

#if LLVM_VERSION_MINOR >= 5
extern "C" const uint32_t RispLLVMDebugMetadataVersion = DEBUG_METADATA_VERSION;
#else
extern "C" const uint32_t RispLLVMDebugMetadataVersion = 1;
#endif

extern "C" void RispLLVMAddModuleFlag(LLVMModuleRef M,
                                      const char *name,
                                      uint32_t value) {
    unwrap(M)->addModuleFlag(Module::Warning, name, value);
}

extern "C" DIBuilderRef RispLLVMDIBuilderCreate(LLVMModuleRef M) {
    return new DIBuilder(*unwrap(M));
}

extern "C" void RispLLVMDIBuilderDispose(DIBuilderRef Builder) {
    delete Builder;
}

extern "C" void RispLLVMDIBuilderFinalize(DIBuilderRef Builder) {
    Builder->finalize();
}

extern "C" void RispLLVMDIBuilderCreateCompileUnit(
                                               DIBuilderRef Builder,
                                               unsigned Lang,
                                               const char* File,
                                               const char* Dir,
                                               const char* Producer,
                                               bool isOptimized,
                                               const char* Flags,
                                               unsigned RuntimeVer,
                                               const char* SplitName) {
    Builder->createCompileUnit(Lang, File, Dir, Producer, isOptimized,
                               Flags, RuntimeVer, SplitName);
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateFile(
                                                DIBuilderRef Builder,
                                                const char* Filename,
                                                const char* Directory) {
    return wrap(Builder->createFile(Filename, Directory));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateSubroutineType(
                                                          DIBuilderRef Builder,
                                                          LLVMValueRef File,
                                                          LLVMValueRef ParameterTypes) {
    return wrap(Builder->createSubroutineType(
                                              unwrapDI<DIFile>(File),
                                              unwrapDI<DIArray>(ParameterTypes)));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateFunction(
                                                    DIBuilderRef Builder,
                                                    LLVMValueRef Scope,
                                                    const char* Name,
                                                    const char* LinkageName,
                                                    LLVMValueRef File,
                                                    unsigned LineNo,
                                                    LLVMValueRef Ty,
                                                    bool isLocalToUnit,
                                                    bool isDefinition,
                                                    unsigned ScopeLine,
                                                    unsigned Flags,
                                                    bool isOptimized,
                                                    LLVMValueRef Fn,
                                                    LLVMValueRef TParam,
                                                    LLVMValueRef Decl) {
    return wrap(Builder->createFunction(
                                        unwrapDI<DIScope>(Scope), Name, LinkageName,
                                        unwrapDI<DIFile>(File), LineNo,
                                        unwrapDI<DICompositeType>(Ty), isLocalToUnit, isDefinition, ScopeLine,
                                        Flags, isOptimized,
                                        unwrap<Function>(Fn),
                                        unwrapDI<MDNode*>(TParam),
                                        unwrapDI<MDNode*>(Decl)));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateBasicType(
                                                     DIBuilderRef Builder,
                                                     const char* Name,
                                                     uint64_t SizeInBits,
                                                     uint64_t AlignInBits,
                                                     unsigned Encoding) {
    return wrap(Builder->createBasicType(
                                         Name, SizeInBits,
                                         AlignInBits, Encoding));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreatePointerType(
                                                       DIBuilderRef Builder,
                                                       LLVMValueRef PointeeTy,
                                                       uint64_t SizeInBits,
                                                       uint64_t AlignInBits,
                                                       const char* Name) {
    return wrap(Builder->createPointerType(
                                           unwrapDI<DIType>(PointeeTy), SizeInBits, AlignInBits, Name));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateStructType(
                                                      DIBuilderRef Builder,
                                                      LLVMValueRef Scope,
                                                      const char* Name,
                                                      LLVMValueRef File,
                                                      unsigned LineNumber,
                                                      uint64_t SizeInBits,
                                                      uint64_t AlignInBits,
                                                      unsigned Flags,
                                                      LLVMValueRef DerivedFrom,
                                                      LLVMValueRef Elements,
                                                      unsigned RunTimeLang,
                                                      LLVMValueRef VTableHolder,
                                                      const char *UniqueId) {
    return wrap(Builder->createStructType(
                                          unwrapDI<DIDescriptor>(Scope),
                                          Name,
                                          unwrapDI<DIFile>(File),
                                          LineNumber,
                                          SizeInBits,
                                          AlignInBits,
                                          Flags,
                                          unwrapDI<DIType>(DerivedFrom),
                                          unwrapDI<DIArray>(Elements),
                                          RunTimeLang,
                                          unwrapDI<DIType>(VTableHolder)
#if LLVM_VERSION_MINOR >= 4
                                          ,UniqueId
#endif
                                          ));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateMemberType(
                                                      DIBuilderRef Builder,
                                                      LLVMValueRef Scope,
                                                      const char* Name,
                                                      LLVMValueRef File,
                                                      unsigned LineNo,
                                                      uint64_t SizeInBits,
                                                      uint64_t AlignInBits,
                                                      uint64_t OffsetInBits,
                                                      unsigned Flags,
                                                      LLVMValueRef Ty) {
    return wrap(Builder->createMemberType(
                                          unwrapDI<DIDescriptor>(Scope), Name,
                                          unwrapDI<DIFile>(File), LineNo,
                                          SizeInBits, AlignInBits, OffsetInBits, Flags,
                                          unwrapDI<DIType>(Ty)));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateLexicalBlock(
                                                        DIBuilderRef Builder,
                                                        LLVMValueRef Scope,
                                                        LLVMValueRef File,
                                                        unsigned Line,
                                                        unsigned Col,
                                                        unsigned Discriminator) {
    return wrap(Builder->createLexicalBlock(
                                            unwrapDI<DIDescriptor>(Scope),
                                            unwrapDI<DIFile>(File), Line, Col
#if LLVM_VERSION_MINOR >= 5
                                            , Discriminator
#endif
                                            ));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateStaticVariable(
                                                          DIBuilderRef Builder,
                                                          LLVMValueRef Context,
                                                          const char* Name,
                                                          const char* LinkageName,
                                                          LLVMValueRef File,
                                                          unsigned LineNo,
                                                          LLVMValueRef Ty,
                                                          bool isLocalToUnit,
                                                          LLVMValueRef Val,
                                                          LLVMValueRef Decl = NULL) {
    return wrap(Builder->createStaticVariable(unwrapDI<DIDescriptor>(Context),
                                              Name,
                                              LinkageName,
                                              unwrapDI<DIFile>(File),
                                              LineNo,
                                              unwrapDI<DIType>(Ty),
                                              isLocalToUnit,
                                              unwrap(Val),
                                              unwrapDI<MDNode*>(Decl)));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateLocalVariable(
                                                         DIBuilderRef Builder,
                                                         unsigned Tag,
                                                         LLVMValueRef Scope,
                                                         const char* Name,
                                                         LLVMValueRef File,
                                                         unsigned LineNo,
                                                         LLVMValueRef Ty,
                                                         bool AlwaysPreserve,
                                                         unsigned Flags,
                                                         unsigned ArgNo) {
    return wrap(Builder->createLocalVariable(Tag,
                                             unwrapDI<DIDescriptor>(Scope), Name,
                                             unwrapDI<DIFile>(File),
                                             LineNo,
                                             unwrapDI<DIType>(Ty), AlwaysPreserve, Flags, ArgNo));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateArrayType(
                                                     DIBuilderRef Builder,
                                                     uint64_t Size,
                                                     uint64_t AlignInBits,
                                                     LLVMValueRef Ty,
                                                     LLVMValueRef Subscripts) {
    return wrap(Builder->createArrayType(Size, AlignInBits,
                                         unwrapDI<DIType>(Ty),
                                         unwrapDI<DIArray>(Subscripts)));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateVectorType(
                                                      DIBuilderRef Builder,
                                                      uint64_t Size,
                                                      uint64_t AlignInBits,
                                                      LLVMValueRef Ty,
                                                      LLVMValueRef Subscripts) {
    return wrap(Builder->createVectorType(Size, AlignInBits,
                                          unwrapDI<DIType>(Ty),
                                          unwrapDI<DIArray>(Subscripts)));
}

extern "C" LLVMValueRef RispLLVMDIBuilderGetOrCreateSubrange(
                                                         DIBuilderRef Builder,
                                                         int64_t Lo,
                                                         int64_t Count) {
    return wrap(Builder->getOrCreateSubrange(Lo, Count));
}

extern "C" LLVMValueRef RispLLVMDIBuilderGetOrCreateArray(
                                                      DIBuilderRef Builder,
                                                      LLVMValueRef* Ptr,
                                                      unsigned Count) {
    return wrap(Builder->getOrCreateArray(
                                          ArrayRef<Value*>(reinterpret_cast<Value**>(Ptr), Count)));
}

extern "C" LLVMValueRef RispLLVMDIBuilderInsertDeclareAtEnd(
                                                        DIBuilderRef Builder,
                                                        LLVMValueRef Val,
                                                        LLVMValueRef VarInfo,
                                                        LLVMBasicBlockRef InsertAtEnd) {
    return wrap(Builder->insertDeclare(
                                       unwrap(Val),
                                       unwrapDI<DIVariable>(VarInfo),
                                       unwrap(InsertAtEnd)));
}

extern "C" LLVMValueRef RispLLVMDIBuilderInsertDeclareBefore(
                                                         DIBuilderRef Builder,
                                                         LLVMValueRef Val,
                                                         LLVMValueRef VarInfo,
                                                         LLVMValueRef InsertBefore) {
    return wrap(Builder->insertDeclare(
                                       unwrap(Val),
                                       unwrapDI<DIVariable>(VarInfo),
                                       unwrap<Instruction>(InsertBefore)));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateEnumerator(
                                                      DIBuilderRef Builder,
                                                      const char* Name,
                                                      uint64_t Val)
{
    return wrap(Builder->createEnumerator(Name, Val));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateEnumerationType(
                                                           DIBuilderRef Builder,
                                                           LLVMValueRef Scope,
                                                           const char* Name,
                                                           LLVMValueRef File,
                                                           unsigned LineNumber,
                                                           uint64_t SizeInBits,
                                                           uint64_t AlignInBits,
                                                           LLVMValueRef Elements,
                                                           LLVMValueRef ClassType)
{
    return wrap(Builder->createEnumerationType(
                                               unwrapDI<DIDescriptor>(Scope),
                                               Name,
                                               unwrapDI<DIFile>(File),
                                               LineNumber,
                                               SizeInBits,
                                               AlignInBits,
                                               unwrapDI<DIArray>(Elements),
                                               unwrapDI<DIType>(ClassType)));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateUnionType(
                                                     DIBuilderRef Builder,
                                                     LLVMValueRef Scope,
                                                     const char* Name,
                                                     LLVMValueRef File,
                                                     unsigned LineNumber,
                                                     uint64_t SizeInBits,
                                                     uint64_t AlignInBits,
                                                     unsigned Flags,
                                                     LLVMValueRef Elements,
                                                     unsigned RunTimeLang,
                                                     const char* UniqueId)
{
    return wrap(Builder->createUnionType(
                                         unwrapDI<DIDescriptor>(Scope),
                                         Name,
                                         unwrapDI<DIFile>(File),
                                         LineNumber,
                                         SizeInBits,
                                         AlignInBits,
                                         Flags,
                                         unwrapDI<DIArray>(Elements),
                                         RunTimeLang
#if LLVM_VERSION_MINOR >= 4
                                         ,UniqueId
#endif
                                         ));
}

#if LLVM_VERSION_MINOR < 5
extern "C" void RispLLVMSetUnnamedAddr(LLVMValueRef Value, LLVMBool Unnamed) {
    unwrap<GlobalValue>(Value)->setUnnamedAddr(Unnamed);
}
#endif

extern "C" LLVMValueRef RispLLVMDIBuilderCreateTemplateTypeParameter(
                                                                 DIBuilderRef Builder,
                                                                 LLVMValueRef Scope,
                                                                 const char* Name,
                                                                 LLVMValueRef Ty,
                                                                 LLVMValueRef File,
                                                                 unsigned LineNo,
                                                                 unsigned ColumnNo)
{
    return wrap(Builder->createTemplateTypeParameter(
                                                     unwrapDI<DIDescriptor>(Scope),
                                                     Name,
                                                     unwrapDI<DIType>(Ty),
                                                     unwrapDI<MDNode*>(File),
                                                     LineNo,
                                                     ColumnNo));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateOpDeref(LLVMTypeRef IntTy)
{
    return LLVMConstInt(IntTy, DIBuilder::OpDeref, true);
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateOpPlus(LLVMTypeRef IntTy)
{
    return LLVMConstInt(IntTy, DIBuilder::OpPlus, true);
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateComplexVariable(
                                                           DIBuilderRef Builder,
                                                           unsigned Tag,
                                                           LLVMValueRef Scope,
                                                           const char *Name,
                                                           LLVMValueRef File,
                                                           unsigned LineNo,
                                                           LLVMValueRef Ty,
                                                           LLVMValueRef* AddrOps,
                                                           unsigned AddrOpsCount,
                                                           unsigned ArgNo)
{
    llvm::ArrayRef<llvm::Value*> addr_ops((llvm::Value**)AddrOps, AddrOpsCount);
    
    return wrap(Builder->createComplexVariable(
                                               Tag,
                                               unwrapDI<DIDescriptor>(Scope),
                                               Name,
                                               unwrapDI<DIFile>(File),
                                               LineNo,
                                               unwrapDI<DIType>(Ty),
                                               addr_ops,
                                               ArgNo
                                               ));
}

extern "C" LLVMValueRef RispLLVMDIBuilderCreateNameSpace(
                                                     DIBuilderRef Builder,
                                                     LLVMValueRef Scope,
                                                     const char* Name,
                                                     LLVMValueRef File,
                                                     unsigned LineNo)
{
    return wrap(Builder->createNameSpace(
                                         unwrapDI<DIDescriptor>(Scope),
                                         Name,
                                         unwrapDI<DIFile>(File),
                                         LineNo));
}

extern "C" void RispLLVMDICompositeTypeSetTypeArray(
                                                LLVMValueRef CompositeType,
                                                LLVMValueRef TypeArray)
{
    unwrapDI<DICompositeType>(CompositeType).setTypeArray(unwrapDI<DIArray>(TypeArray));
}

extern "C" char *RispLLVMTypeToString(LLVMTypeRef Type) {
    std::string s;
    llvm::raw_string_ostream os(s);
    unwrap<llvm::Type>(Type)->print(os);
    return strdup(os.str().data());
}

extern "C" char *LLVMValueToString(LLVMValueRef Value) {
    std::string s;
    llvm::raw_string_ostream os(s);
    os << "(";
    unwrap<llvm::Value>(Value)->getType()->print(os);
    os << ":";
    unwrap<llvm::Value>(Value)->print(os);
    os << ")";
    return strdup(os.str().data());
}

#if LLVM_VERSION_MINOR >= 5
extern "C" bool
RispLLVMLinkInExternalBitcode(LLVMModuleRef dst, char *bc, size_t len) {
    Module *Dst = unwrap(dst);
    MemoryBuffer* buf = MemoryBuffer::getMemBufferCopy(StringRef(bc, len));
    ErrorOr<Module *> Src = llvm::getLazyBitcodeModule(buf, Dst->getContext());
    if (!Src) {
        RispLLVMSetLastError(Src.getError().message().c_str());
        delete buf;
        return false;
    }
    
    std::string Err;
    if (Linker::LinkModules(Dst, *Src, Linker::DestroySource, &Err)) {
        RispLLVMSetLastError(Err.c_str());
        return false;
    }
    return true;
}
#else
extern "C" bool
RispLLVMLinkInExternalBitcode(LLVMModuleRef dst, char *bc, size_t len) {
    Module *Dst = unwrap(dst);
    MemoryBuffer* buf = MemoryBuffer::getMemBufferCopy(StringRef(bc, len));
    std::string Err;
    Module *Src = llvm::getLazyBitcodeModule(buf, Dst->getContext(), &Err);
    if (!Src) {
        RispLLVMSetLastError(Err.c_str());
        delete buf;
        return false;
    }
    
    if (Linker::LinkModules(Dst, Src, Linker::DestroySource, &Err)) {
        RispLLVMSetLastError(Err.c_str());
        return false;
    }
    return true;
}
#endif

#if LLVM_VERSION_MINOR >= 5
extern "C" void*
RispLLVMOpenArchive(char *path) {
    std::unique_ptr<MemoryBuffer> buf;
    error_code err = MemoryBuffer::getFile(path, buf);
    if (err) {
        RispLLVMSetLastError(err.message().c_str());
        return NULL;
    }
    Archive *ret = new Archive(buf.release(), err);
    if (err) {
        RispLLVMSetLastError(err.message().c_str());
        return NULL;
    }
    return ret;
}
#else
extern "C" void*
RispLLVMOpenArchive(char *path) {
    OwningPtr<MemoryBuffer> buf;
    error_code err = MemoryBuffer::getFile(path, buf);
    if (err) {
        RispLLVMSetLastError(err.message().c_str());
        return NULL;
    }
    Archive *ret = new Archive(buf.take(), err);
    if (err) {
        RispLLVMSetLastError(err.message().c_str());
        return NULL;
    }
    return ret;
}
#endif

extern "C" const char*
RispLLVMArchiveReadSection(Archive *ar, char *name, size_t *size) {
#if LLVM_VERSION_MINOR >= 5
    Archive::child_iterator child = ar->child_begin(),
    end = ar->child_end();
#else
    Archive::child_iterator child = ar->begin_children(),
    end = ar->end_children();
#endif
    for (; child != end; ++child) {
        StringRef sect_name;
        error_code err = child->getName(sect_name);
        if (err) continue;
        if (sect_name.trim(" ") == name) {
            StringRef buf = child->getBuffer();
            *size = buf.size();
            return buf.data();
        }
    }
    return NULL;
}

extern "C" void
RispLLVMDestroyArchive(Archive *ar) {
    delete ar;
}

#if LLVM_VERSION_MINOR >= 5
extern "C" void
RispLLVMSetDLLExportStorageClass(LLVMValueRef Value) {
    GlobalValue *V = unwrap<GlobalValue>(Value);
    V->setDLLStorageClass(GlobalValue::DLLExportStorageClass);
}
#else
extern "C" void
RispLLVMSetDLLExportStorageClass(LLVMValueRef Value) {
    LLVMSetLinkage(Value, LLVMDLLExportLinkage);
}
#endif

extern "C" int
RispLLVMVersionMinor() {
    return LLVM_VERSION_MINOR;
}

extern "C" int
RispLLVMVersionMajor() {
    return LLVM_VERSION_MAJOR;
}

// Note that the two following functions look quite similar to the
// LLVMGetSectionName function. Sadly, it appears that this function only
// returns a char* pointer, which isn't guaranteed to be null-terminated. The
// function provided by LLVM doesn't return the length, so we've created our own
// function which returns the length as well as the data pointer.
//
// For an example of this not returning a null terminated string, see
// lib/Object/COFFObjectFile.cpp in the getSectionName function. One of the
// branches explicitly creates a StringRef without a null terminator, and then
// that's returned.

inline section_iterator *unwrap(LLVMSectionIteratorRef SI) {
    return reinterpret_cast<section_iterator*>(SI);
}

extern "C" int RispLLVMGetSectionName(LLVMSectionIteratorRef SI, const char **ptr) {
    StringRef ret;
    if (error_code ec = (*unwrap(SI))->getName(ret))
        report_fatal_error(ec.message());
    *ptr = ret.data();
    return ret.size();
}

// LLVMArrayType function does not support 64-bit ElementCount
extern "C" LLVMTypeRef RispLLVMArrayType(LLVMTypeRef ElementType, uint64_t ElementCount) {
    return wrap(ArrayType::get(unwrap(ElementType), ElementCount));
}