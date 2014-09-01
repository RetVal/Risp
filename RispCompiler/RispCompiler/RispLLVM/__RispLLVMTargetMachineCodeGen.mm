//
//  __RispLLVMTargetMachineCodeGen.cpp
//  Risp
//
//  Created by closure on 8/9/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#include "__RispLLVMTargetMachineCodeGen.h"
#include "llvm/CodeGen/CommandFlags.h"
#include "llvm/CodeGen/LinkAllAsmWriterComponents.h"
#include "llvm/CodeGen/LinkAllCodegenComponents.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/MC/SubtargetFeature.h"
#include "llvm/Pass.h"
#include "llvm/PassManager.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/PluginLoader.h"
#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/Signals.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Target/TargetLibraryInfo.h"
#include "llvm/Target/TargetMachine.h"
#include <memory>

namespace RispLLVM {
    static llvm::TargetMachine::CodeGenFileType codegenFileTypeTranform(RispLLVM::RispTargetMachineCodeGenOutputFileType fileType) {
        switch (fileType) {
            case RispLLVM::RispTargetMachineCodeGenOutputFileType::AssemblyFile:
                return llvm::TargetMachine::CodeGenFileType::CGFT_AssemblyFile;
            case RispLLVM::RispTargetMachineCodeGenOutputFileType::ObjectFile:
                return llvm::TargetMachine::CodeGenFileType::CGFT_ObjectFile;
            case RispLLVM::RispTargetMachineCodeGenOutputFileType::Null:
                return llvm::TargetMachine::CodeGenFileType::CGFT_Null;
        }
        return llvm::TargetMachine::CodeGenFileType::CGFT_Null;
    }
}

@implementation __RispLLVMTargetMachineCodeGen
+ (void)initialize {
    EnableDebugBuffering = YES;
    llvm::InitializeAllTargets();
    llvm::InitializeAllTargetMCs();
    llvm::InitializeAllAsmPrinters();
    llvm::InitializeAllAsmParsers();
    
    llvm::PassRegistry *Registry = llvm::PassRegistry::getPassRegistry();
    llvm::initializeCore(*Registry);
    llvm::initializeCodeGen(*Registry);
    llvm::initializeLoopStrengthReducePass(*Registry);
    llvm::initializeLowerIntrinsicsPass(*Registry);
    llvm::initializeUnreachableBlockElimPass(*Registry);
    
    // Register the target printer for --version.
    cl::AddExtraVersionPrinter(llvm::TargetRegistry::printRegisteredTargetsForVersion);
}

+ (NSUInteger)compileObjectModule:(llvm::Module *)module context:(llvm::LLVMContext &)context outputPath:(NSString *)outputPath {
    outputPath = [outputPath stringByStandardizingPath];
    llvm::sys::fs::OpenFlags openFlags = sys::fs::F_None;
    std::string error;
    std::unique_ptr<llvm::tool_output_file> of(new llvm::tool_output_file([outputPath UTF8String], error, openFlags));
    NSUInteger ret = [self compileModule:module context:context targetNamed:MArch targetTriple:"" optLevel:llvm::CodeGenOpt::Default isNoIntegratedAssembler:NO isEnableDwarfDirectory:NO isGenerateSoftFloatCalls:NO isDisableSimplifyLibCalls:NO isRelaxAll:NO noVerify:NO fileType:RispLLVM::RispTargetMachineCodeGenOutputFileType::ObjectFile startAfter:"" stopAfter:"" outputStream:of->os()];
    if (ret == 0) {
        of->keep();
    }
    return ret;
}

+ (NSUInteger)compileASMModule:(llvm::Module *)module context:(llvm::LLVMContext &)context output:(std::string &)output {
    llvm::raw_string_ostream sos(output);
    return [self compileModule:module context:context targetNamed:MArch targetTriple:"" optLevel:llvm::CodeGenOpt::Default isNoIntegratedAssembler:NO isEnableDwarfDirectory:NO isGenerateSoftFloatCalls:NO isDisableSimplifyLibCalls:NO isRelaxAll:NO noVerify:NO fileType:RispLLVM::RispTargetMachineCodeGenOutputFileType::AssemblyFile startAfter:"" stopAfter:"" outputStream:sos];
}

+ (NSInteger)compileModule:(llvm::Module *)module context:(llvm::LLVMContext &)context targetNamed:(std::string)march targetTriple:(std::string)targetTriple optLevel:(NSUInteger)level isNoIntegratedAssembler:(BOOL)noIntegratedAssembler isEnableDwarfDirectory:(BOOL)enableDwarfDirectory isGenerateSoftFloatCalls:(BOOL)generateSoftFloatCalls isDisableSimplifyLibCalls:(BOOL)disableSimplifyLibCalls isRelaxAll:(BOOL)relaxAll noVerify:(BOOL)noVerify fileType:(RispLLVM::RispTargetMachineCodeGenOutputFileType)fileType startAfter:(std::string)startAfter stopAfter:(std::string)stopAfter outputStream:(llvm::raw_ostream&)outputStream {
    llvm::Triple theTriple;
    
//    BOOL skipModule = MCPU == "help" || (!MAttrs.empty() && MAttrs.front() == "help");
    
    if (MCPU == "native") {
        MCPU = llvm::sys::getHostCPUName();
    }
    
    if (!targetTriple.empty()) {
        module->setTargetTriple(llvm::Triple::normalize(targetTriple));
    }
    theTriple = llvm::Triple(module->getTargetTriple());
    if (theTriple.getTriple().empty()) {
        theTriple.setTriple(llvm::sys::getDefaultTargetTriple());
    }
    std::string error;
    const llvm::Target *theTarget = llvm::TargetRegistry::lookupTarget(march, theTriple, error);
    if (!theTarget) {
        llvm::errs() << ": " << error;
        return 1;
    }
    
    std::string featureStr;
    if (MAttrs.size()) {
        llvm::SubtargetFeatures features;
        for (unsigned i = 0; i != MAttrs.size(); i++) {
            features.AddFeature(MAttrs[i]);
        }
        featureStr = features.getString();
    }
    
    llvm::CodeGenOpt::Level optLevel = llvm::CodeGenOpt::Default;
    switch (level) {
        case 0: optLevel = llvm::CodeGenOpt::None; break;
        case 1: optLevel = llvm::CodeGenOpt::Less; break;
        case 2: optLevel = llvm::CodeGenOpt::Default; break;
        case 3: optLevel = llvm::CodeGenOpt::Aggressive; break;
        default: llvm::errs() << ": invalid optimization level.\n"; return 1;
    }
    llvm::TargetOptions options = InitTargetOptionsFromCodeGenFlags();
    options.DisableIntegratedAS = noIntegratedAssembler;
    std::unique_ptr<llvm::TargetMachine> target(theTarget->createTargetMachine(theTriple.getTriple(), MCPU, featureStr, options, RelocModel, CMModel, optLevel));
    assert(target.get() && "Could not allocate target machine!");
    assert(module && "Should have exited after outputting help!");
    llvm::TargetMachine &Target = *target.get();
    if (enableDwarfDirectory) {
        Target.setMCUseDwarfDirectory(YES);
    }
    
    if (generateSoftFloatCalls) {
        FloatABIForCalls = llvm::FloatABI::Soft;
    }
    
    llvm::PassManager pm;
    llvm::TargetLibraryInfo *tli = new TargetLibraryInfo(theTriple);
    if (disableSimplifyLibCalls ) {
        tli->disableAllFunctions();
    }
    pm.add(tli);
    if (const llvm::DataLayout *dl = Target.getDataLayout()) {
        module->setDataLayout(dl);
    }
    pm.add(new DataLayoutPass(module));
    
    Target.setAsmVerbosityDefault(YES);
    if (relaxAll) {
        if (fileType != RispLLVM::RispTargetMachineCodeGenOutputFileType::ObjectFile) {
            llvm::errs() << ": warnning: ignoring -mc-relax-all because filetype != obj\n";
        } else {
            Target.setMCRelaxAll(YES);
        }
    }
    
    llvm::formatted_raw_ostream fos(outputStream);
    llvm::AnalysisID startAfterID = nullptr;
    llvm::AnalysisID stopAfterID = nullptr;
    const llvm::PassRegistry *pr = llvm::PassRegistry::getPassRegistry();
    if (!startAfter.empty()) {
        const llvm::PassInfo *pi = pr->getPassInfo(startAfter);
        if (!pi) {
            llvm::errs() << ": start-after pass is not registered.\n";
            return 1;
        }
        startAfterID = pi->getTypeInfo();
    }
    
    if (!stopAfter.empty()) {
        const llvm::PassInfo *pi = pr->getPassInfo(stopAfter);
        if (!pi) {
            llvm::errs() << ": stop-after pass is not registed.\n";
            return 1;
        }
        stopAfterID = pi->getTypeInfo();
    }
    
    if (Target.addPassesToEmitFile(pm, fos, RispLLVM::codegenFileTypeTranform(fileType), noVerify, startAfterID, stopAfterID)) {
        llvm::errs() << ": target does not support generation of this file type!\n";
        return 1;
    }
    pm.run(*module);
    return 0;
}
@end