//
//  CodeGenModule.cpp
//  Risp
//
//  Created by closure on 8/11/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#include "CodeGenFunction.h"
#include "CGBlockInfo.h"
#include "llvm/IR/Function.h"

namespace RispLLVM {
    const unsigned BlockHeaderSize = 5;
    
    enum BlockByrefFlags {
        BLOCK_BYREF_HAS_COPY_DISPOSE         = (1   << 25), // compiler
        BLOCK_BYREF_LAYOUT_MASK              = (0xF << 28), // compiler
        BLOCK_BYREF_LAYOUT_EXTENDED          = (1   << 28),
        BLOCK_BYREF_LAYOUT_NON_OBJECT        = (2   << 28),
        BLOCK_BYREF_LAYOUT_STRONG            = (3   << 28),
        BLOCK_BYREF_LAYOUT_WEAK              = (4   << 28),
        BLOCK_BYREF_LAYOUT_UNRETAINED        = (5   << 28)
    };
    
    enum BlockLiteralFlags {
        BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
        BLOCK_HAS_CXX_OBJ =       (1 << 26),
        BLOCK_IS_GLOBAL =         (1 << 28),
        BLOCK_USE_STRET =         (1 << 29),
        BLOCK_HAS_SIGNATURE  =    (1 << 30),
        BLOCK_HAS_EXTENDED_LAYOUT = (1 << 31)
    };
    class BlockFlags {
        uint32_t flags;
        
    public:
        BlockFlags(uint32_t flags) : flags(flags) {}
        BlockFlags() : flags(0) {}
        BlockFlags(BlockLiteralFlags flag) : flags(flag) {}
        BlockFlags(BlockByrefFlags flag) : flags(flag) {}
        
        uint32_t getBitMask() const { return flags; }
        bool empty() const { return flags == 0; }
        
        friend BlockFlags operator|(BlockFlags l, BlockFlags r) {
            return BlockFlags(l.flags | r.flags);
        }
        friend BlockFlags &operator|=(BlockFlags &l, BlockFlags r) {
            l.flags |= r.flags;
            return l;
        }
        friend bool operator&(BlockFlags l, BlockFlags r) {
            return (l.flags & r.flags);
        }
        bool operator==(BlockFlags r) {
            return (flags == r.flags);
        }
    };
    
    /// Build the given block as a global block.
    static llvm::Constant *buildGlobalBlock(__RispLLVMFoundation *CGM,
                                            const CGBlockInfo &blockInfo,
                                            llvm::Constant *blockFn);
    
    /// Build the helper function to copy a block.
    static llvm::Constant *buildCopyHelper(__RispLLVMFoundation *CGM,
                                           const CGBlockInfo &blockInfo) {
        return CodeGenFunction(CGM).GenerateCopyHelperFunction(blockInfo);
    }
    
    static llvm::Constant *buildDisposeHelper(__RispLLVMFoundation *CGM,
                                              const CGBlockInfo &blockInfo) {
        return CodeGenFunction(CGM).GenerateDestroyHelperFunction(blockInfo);
    }
    
    static void configureBlocksRuntimeObject(CodeGenFunction &CGF, llvm::Constant *C) {
//        if (!CGM.getLangOpts().BlocksRuntimeOptional) return;
        
        llvm::GlobalValue *GV = llvm::cast<llvm::GlobalValue>(C->stripPointerCasts());
        if (GV->isDeclaration() &&
            GV->getLinkage() == llvm::GlobalValue::ExternalLinkage)
            GV->setLinkage(llvm::GlobalValue::ExternalWeakLinkage);
    }
    
    static llvm::Constant *createARCRuntimeFunction(__RispLLVMFoundation *CGM,
                                                    llvm::FunctionType *type,
                                                    llvm::StringRef fnName) {
        llvm::Constant *fn = [CGM createRuntimeFunciton:type name:fnName extraAttributes:llvm::AttributeSet()];
        
        if (llvm::Function *f = llvm::dyn_cast<llvm::Function>(fn)) {
            // If the target runtime doesn't naturally support ARC, emit weak
            // references to the runtime support library.  We don't really
            // permit this to fail, but we need a particular relocation style.
            if (!([[CGM targetCodeGenInfo] languageOption] & RispLLVMLanguageARC)) {
                f->setLinkage(llvm::Function::ExternalWeakLinkage);
            } else if (fnName == "objc_retain" || fnName  == "objc_release") {
                // If we have Native ARC, set nonlazybind attribute for these APIs for
                // performance.
                f->addFnAttr(llvm::Attribute::NonLazyBind);
            }
        }
        
        return fn;
    }
    
    llvm::Constant *CodeGenFunction::getBlockObjectDispose() {
        if (BlockObjectDispose)
            return BlockObjectDispose;
        
        llvm::Type *args[] = { [CGM charType], [CGM intType] };
        llvm::FunctionType *fty
        = llvm::FunctionType::get([CGM voidType], args, false);
        BlockObjectDispose = [CGM createRuntimeFunciton:fty name:"_Block_object_dispose" extraAttributes:llvm::AttributeSet()];
        configureBlocksRuntimeObject(*this, BlockObjectDispose);
        return BlockObjectDispose;
    }
    
    llvm::Constant *CodeGenFunction::getBlockObjectAssign() {
        if (BlockObjectAssign)
            return BlockObjectAssign;
        
        llvm::Type *args[] = { [CGM charType], [CGM charType], [CGM intType] };
        llvm::FunctionType *fty
        = llvm::FunctionType::get([CGM intType], args, false);
        BlockObjectAssign = [CGM createRuntimeFunciton:fty name:"_Block_object_assign" extraAttributes:llvm::AttributeSet()];
        configureBlocksRuntimeObject(*this, BlockObjectAssign);
        return BlockObjectAssign;
    }
    
    llvm::Constant *CodeGenFunction::getNSConcreteGlobalBlock() {
        if (NSConcreteGlobalBlock)
            return NSConcreteGlobalBlock;
        NSConcreteGlobalBlock = [CGM getOrCreateLLVMGlobal:"_NSConcreteGlobalBlock" type:[CGM idType] unnamedAddress:NO];
        configureBlocksRuntimeObject(*this, NSConcreteGlobalBlock);
        return NSConcreteGlobalBlock;
    }
    
    llvm::Constant *CodeGenFunction::getNSConcreteStackBlock() {
        if (NSConcreteStackBlock)
            return NSConcreteStackBlock;
        
        NSConcreteStackBlock = [CGM getOrCreateLLVMGlobal:"_NSConcreteStackBlock" type:[CGM idType] unnamedAddress:NO];
        configureBlocksRuntimeObject(*this, NSConcreteStackBlock);
        return NSConcreteStackBlock;
    }
    
    llvm::Type *CodeGenFunction::getBlockDescriptorType() {
        if (BlockDescriptorType)
            return BlockDescriptorType;
        
        llvm::Type *UnsignedLongTy = [CGM llvmTypeFromObjectiveCType:@encode(unsigned long)];
        
        // struct __block_descriptor {
        //   unsigned long reserved;
        //   unsigned long block_size;
        //
        //   // later, the following will be added
        //
        //   struct {
        //     void (*copyHelper)();
        //     void (*copyHelper)();
        //   } helpers;                // !!! optional
        //
        //   const char *signature;   // the block signature
        //   const char *layout;      // reserved
        // };
        BlockDescriptorType = llvm::StructType::create("struct.__block_descriptor",
                                                       UnsignedLongTy, UnsignedLongTy, NULL);
        
        // Now form a pointer to that.
        BlockDescriptorType = llvm::PointerType::getUnqual(BlockDescriptorType);
        return BlockDescriptorType;
    }
    
    llvm::Type *CodeGenFunction::getGenericBlockLiteralType() {
        if (GenericBlockLiteralType)
            return GenericBlockLiteralType;
        
        llvm::Type *BlockDescPtrTy = getBlockDescriptorType();
        
        // struct __block_literal_generic {
        //   void *__isa;
        //   int __flags;
        //   int __reserved;
        //   void (*__invoke)(void *);
        //   struct __block_descriptor *__descriptor;
        // };
        GenericBlockLiteralType = llvm::StructType::create("struct.__block_literal_generic",
                                                           [CGM voidType]->getPointerTo(), [CGM intType], [CGM intType], [CGM voidType]->getPointerTo(),
                                                           BlockDescPtrTy, NULL);
        
        return GenericBlockLiteralType;
    }
    
    llvm::CallInst *
    CodeGenFunction::EmitNounwindRuntimeCall(llvm::Value *callee,
                                             const llvm::Twine &name) {
        return EmitNounwindRuntimeCall(callee, llvm::ArrayRef<llvm::Value*>(), name);
    }
    
    /// Emits a call to the given nounwind runtime function.
    llvm::CallInst *
    CodeGenFunction::EmitNounwindRuntimeCall(llvm::Value *callee,
                                             llvm::ArrayRef<llvm::Value*> args,
                                             const llvm::Twine &name) {
        llvm::CallInst *call = EmitRuntimeCall(callee, args, name);
        call->setDoesNotThrow();
        return call;
    }
    
    /// Emits a simple call (never an invoke) to the given no-arguments
    /// runtime function.
    llvm::CallInst *
    CodeGenFunction::EmitRuntimeCall(llvm::Value *callee,
                                     const llvm::Twine &name) {
        return EmitRuntimeCall(callee, llvm::ArrayRef<llvm::Value*>(), name);
    }
    
    /// Emits a simple call (never an invoke) to the given runtime
    /// function.
    llvm::CallInst *
    CodeGenFunction::EmitRuntimeCall(llvm::Value *callee,
                                     llvm::ArrayRef<llvm::Value*> args,
                                     const llvm::Twine &name) {
        llvm::CallInst *call = Builder->CreateCall(callee, args, name);
        call->setCallingConv([[CGM targetCodeGenInfo] runtimeCC]);
        return call;
    }

    
    struct __block_literal_1 {
        void *isa;
        int flags;
        int reserved;
        void (*invoke)(struct __block_literal_1 *);
        struct __block_descriptor_1 *descriptor;
    };
    
    void __block_invoke_1(struct __block_literal_1 *_block) {
        printf("hello world\n");
    }
    
    static struct __block_descriptor_1 {
        unsigned long int reserved;
        unsigned long int Block_size;
    } __block_descriptor_1 = { 0, sizeof(struct __block_literal_1) };
    
    struct __block_literal_1 _block_literal = {
        &_NSConcreteStackBlock,
        (1<<29),
        0,
        __block_invoke_1,
        &__block_descriptor_1
    };
    
    static llvm::Constant *buildBlockDescriptor(CodeGenFunction &CGF, const CGBlockInfo &blockInfo) {
        llvm::DenseMapInfo<llvm::Type *> d;
        
//        ASTContext &C = CGM.getContext();
        __RispLLVMFoundation *CGM = CGF.CGM;
        llvm::Type *ulong = [CGM llvmTypeFromObjectiveCType:@encode(unsigned long)];
        llvm::Type *i8p = [CGM voidType];
        
        llvm::SmallVector<llvm::Constant*, 6> elements;
        
        // reserved
        elements.push_back(llvm::ConstantInt::get(ulong, 0));
        
        // Size
        // FIXME: What is the right way to say this doesn't fit?  We should give
        // a user diagnostic in that case.  Better fix would be to change the
        // API to size_t.
        elements.push_back(llvm::ConstantInt::get(ulong,
                                                  blockInfo.BlockSize.getQuantity()));
        
        // Optional copy/dispose helpers.
        if (blockInfo.NeedsCopyDispose) {
            // copy_func_helper_decl
            elements.push_back(buildCopyHelper(CGM, blockInfo));
            
            // destroy_func_decl
            elements.push_back(buildDisposeHelper(CGM, blockInfo));
        }
        
        // Signature.  Mandatory ObjC-style method descriptor @encode sequence.
        std::string typeAtEncoding = "";
//        CGM.getContext().getObjCEncodingForBlock(blockInfo.getBlockExpr());
        elements.push_back(llvm::ConstantExpr::getBitCast([CGM getAddrOfConstantString:typeAtEncoding globalName:"" alignment:0], i8p));
        
        // GC layout.
//        if (C.getLangOpts().ObjC1) {
//            if (CGM.getLangOpts().getGC() != LangOptions::NonGC)
//                elements.push_back(CGM.getObjCRuntime().BuildGCBlockLayout(CGM, blockInfo));
//            else
//                elements.push_back(CGM.getObjCRuntime().BuildRCBlockLayout(CGM, blockInfo));
//        }
//        else
            elements.push_back(llvm::Constant::getNullValue(i8p));
        
        llvm::Constant *init = llvm::ConstantStruct::getAnon(elements);
        
        llvm::GlobalVariable *global =
        new llvm::GlobalVariable(*[CGM module], init->getType(), true,
                                 llvm::GlobalValue::InternalLinkage,
                                 init, "__block_descriptor_tmp");
        
        return llvm::ConstantExpr::getBitCast(global, CGF.getBlockDescriptorType());
    }
//
//    static llvm::Constant *buildGlobalBlock(CodeGenFunction &CGF,
//                                            const CGBlockInfo &blockInfo,
//                                            llvm::Constant *blockFn) {
//        assert(blockInfo.CanBeGlobal);
//        
//        // Generate the constants for the block literal initializer.
//        llvm::Constant *fields[BlockHeaderSize];
//        
//        // isa
//        fields[0] = CGF.getNSConcreteGlobalBlock();
//        
//        // __flags
//        BlockFlags flags = BLOCK_IS_GLOBAL | BLOCK_HAS_SIGNATURE;
//        if (blockInfo.UsesStret) flags |= BLOCK_USE_STRET;
//        
//        fields[1] = llvm::ConstantInt::get([CGF.CGM intType], flags.getBitMask());
//        
//        // Reserved
//        fields[2] = llvm::Constant::getNullValue([CGF.CGM intType]);
//        
//        // Function
//        fields[3] = blockFn;
//        
//        // Descriptor
//        fields[4] = buildBlockDescriptor(CGF, blockInfo);
//        
//        llvm::Constant *init = llvm::ConstantStruct::getAnon(fields);
//        
//        llvm::GlobalVariable *literal =
//        new llvm::GlobalVariable(*[CGF.CGM module],
//                                 init->getType(),
//                                 /*constant*/ true,
//                                 llvm::GlobalVariable::InternalLinkage,
//                                 init,
//                                 "__block_literal_global");
//        literal->setAlignment(blockInfo.BlockAlign.getQuantity());
//        
//        // Return a constant of the appropriately-casted type.
//        llvm::Type *requiredType = CGM.getTypes().ConvertType(blockInfo.getBlockExpr()->getType());
//        return llvm::ConstantExpr::getBitCast(literal, requiredType);
//    }
    
    /// Generate the copy-helper function for a block closure object:
    ///   static void block_copy_helper(block_t *dst, block_t *src);
    /// The runtime will have previously initialized 'dst' by doing a
    /// bit-copy of 'src'.
    ///
    /// Note that this copies an entire block closure object to the heap;
    /// it should not be confused with a 'byref copy helper', which moves
    /// the contents of an individual __block variable to the heap.
    llvm::Constant *
    CodeGenFunction::GenerateCopyHelperFunction(const CGBlockInfo &blockInfo) {
        return nullptr;
//        llvm::SmallVector<llvm::Type *, 2> args;
//        args.push_back([CGM voidType]->getPointerTo());
//        args.push_back([CGM voidType]->getPointerTo());
//      
//        // FIXME: it would be nice if these were mergeable with things with
//        // identical semantics.
//        llvm::FunctionType *LTy = llvm::FunctionType::get([CGM voidType], args, false);
//        
//        llvm::Function *Fn = llvm::Function::Create(LTy, llvm::GlobalValue::InternalLinkage, "__copy_helper_block_", [CGM module]);
//        
//        IdentifierInfo *II = new IdentifierInfo("__copy_helper_block_");
//        
//        FunctionDecl *FD = FunctionDecl::Create(C,
//                                                C.getTranslationUnitDecl(),
//                                                SourceLocation(),
//                                                SourceLocation(), II, C.VoidTy, 0,
//                                                SC_Static,
//                                                false,
//                                                false);
//        // Create a scope with an artificial location for the body of this function.
//        ArtificialLocation AL(*this, Builder);
//        StartFunction(FD, C.VoidTy, Fn, FI, args);
//        AL.Emit();
//        
//        llvm::Type *structPtrTy = blockInfo.StructureType->getPointerTo();
//        
//        llvm::Value *src = GetAddrOfLocalVar(&srcDecl);
//        src = Builder->CreateLoad(src);
//        src = Builder->CreateBitCast(src, structPtrTy, "block.source");
//        
//        llvm::Value *dst = GetAddrOfLocalVar(&dstDecl);
//        dst = Builder->CreateLoad(dst);
//        dst = Builder->CreateBitCast(dst, structPtrTy, "block.dest");
//        
//        const BlockDecl *blockDecl = blockInfo.getBlockDecl();
//        
//        for (const auto &CI : blockDecl->captures()) {
//            const VarDecl *variable = CI.getVariable();
//            QualType type = variable->getType();
//            
//            const CGBlockInfo::Capture &capture = blockInfo.getCapture(variable);
//            if (capture.isConstant()) continue;
//            
//            const Expr *copyExpr = CI.getCopyExpr();
//            BlockFieldFlags flags;
//            
//            bool useARCWeakCopy = false;
//            bool useARCStrongCopy = false;
//            
//            if (copyExpr) {
//                assert(!CI.isByRef());
//                // don't bother computing flags
//                
//            } else if (CI.isByRef()) {
//                flags = BLOCK_FIELD_IS_BYREF;
//                if (type.isObjCGCWeak())
//                    flags |= BLOCK_FIELD_IS_WEAK;
//                
//            } else if (type->isObjCRetainableType()) {
//                flags = BLOCK_FIELD_IS_OBJECT;
//                bool isBlockPointer = type->isBlockPointerType();
//                if (isBlockPointer)
//                    flags = BLOCK_FIELD_IS_BLOCK;
//                
//                // Special rules for ARC captures:
//                if (getLangOpts().ObjCAutoRefCount) {
//                    Qualifiers qs = type.getQualifiers();
//                    
//                    // We need to register __weak direct captures with the runtime.
//                    if (qs.getObjCLifetime() == Qualifiers::OCL_Weak) {
//                        useARCWeakCopy = true;
//                        
//                        // We need to retain the copied value for __strong direct captures.
//                    } else if (qs.getObjCLifetime() == Qualifiers::OCL_Strong) {
//                        // If it's a block pointer, we have to copy the block and
//                        // assign that to the destination pointer, so we might as
//                        // well use _Block_object_assign.  Otherwise we can avoid that.
//                        if (!isBlockPointer)
//                            useARCStrongCopy = true;
//                        
//                        // Otherwise the memcpy is fine.
//                    } else {
//                        continue;
//                    }
//                    
//                    // Non-ARC captures of retainable pointers are strong and
//                    // therefore require a call to _Block_object_assign.
//                } else {
//                    // fall through
//                }
//            } else {
//                continue;
//            }
//            
//            unsigned index = capture.getIndex();
//            llvm::Value *srcField = Builder.CreateStructGEP(src, index);
//            llvm::Value *dstField = Builder.CreateStructGEP(dst, index);
//            
//            // If there's an explicit copy expression, we do that.
//            if (copyExpr) {
//                EmitSynthesizedCXXCopyCtor(dstField, srcField, copyExpr);
//            } else if (useARCWeakCopy) {
//                EmitARCCopyWeak(dstField, srcField);
//            } else {
//                llvm::Value *srcValue = Builder.CreateLoad(srcField, "blockcopy.src");
//                if (useARCStrongCopy) {
//                    // At -O0, store null into the destination field (so that the
//                    // storeStrong doesn't over-release) and then call storeStrong.
//                    // This is a workaround to not having an initStrong call.
//                    if (CGM.getCodeGenOpts().OptimizationLevel == 0) {
//                        llvm::PointerType *ty = cast<llvm::PointerType>(srcValue->getType());
//                        llvm::Value *null = llvm::ConstantPointerNull::get(ty);
//                        Builder.CreateStore(null, dstField);
//                        EmitARCStoreStrongCall(dstField, srcValue, true);
//                        
//                        // With optimization enabled, take advantage of the fact that
//                        // the blocks runtime guarantees a memcpy of the block data, and
//                        // just emit a retain of the src field.
//                    } else {
//                        EmitARCRetainNonBlock(srcValue);
//                        
//                        // We don't need this anymore, so kill it.  It's not quite
//                        // worth the annoyance to avoid creating it in the first place.
//                        cast<llvm::Instruction>(dstField)->eraseFromParent();
//                    }
//                } else {
//                    srcValue = Builder.CreateBitCast(srcValue, VoidPtrTy);
//                    llvm::Value *dstAddr = Builder.CreateBitCast(dstField, VoidPtrTy);
//                    llvm::Value *args[] = {
//                        dstAddr, srcValue, llvm::ConstantInt::get(Int32Ty, flags.getBitMask())
//                    };
//                    
//                    bool copyCanThrow = false;
//                    if (CI.isByRef() && variable->getType()->getAsCXXRecordDecl()) {
//                        const Expr *copyExpr =
//                        CGM.getContext().getBlockVarCopyInits(variable);
//                        if (copyExpr) {
//                            copyCanThrow = true; // FIXME: reuse the noexcept logic
//                        }
//                    }
//                    
//                    if (copyCanThrow) {
//                        EmitRuntimeCallOrInvoke(CGM.getBlockObjectAssign(), args);
//                    } else {
//                        EmitNounwindRuntimeCall(CGM.getBlockObjectAssign(), args);
//                    }
//                }
//            }
//        }
//        
//        FinishFunction();
//        
//        return llvm::ConstantExpr::getBitCast(Fn, VoidPtrTy);
    }
    
    llvm::Constant *
    CodeGenFunction::GenerateDestroyHelperFunction(const CGBlockInfo &blockInfo) {
        return nullptr;
//        ASTContext &C = getContext();
//        
//        FunctionArgList args;
//        ImplicitParamDecl srcDecl(0, SourceLocation(), 0, C.VoidPtrTy);
//        args.push_back(&srcDecl);
//        
//        const CGFunctionInfo &FI = CGM.getTypes().arrangeFreeFunctionDeclaration(
//                                                                                 C.VoidTy, args, FunctionType::ExtInfo(), /*variadic=*/false);
//        
//        // FIXME: We'd like to put these into a mergable by content, with
//        // internal linkage.
//        llvm::FunctionType *LTy = CGM.getTypes().GetFunctionType(FI);
//        
//        llvm::Function *Fn =
//        llvm::Function::Create(LTy, llvm::GlobalValue::InternalLinkage,
//                               "__destroy_helper_block_", &CGM.getModule());
//        
//        IdentifierInfo *II
//        = &CGM.getContext().Idents.get("__destroy_helper_block_");
//        
//        FunctionDecl *FD = FunctionDecl::Create(C, C.getTranslationUnitDecl(),
//                                                SourceLocation(),
//                                                SourceLocation(), II, C.VoidTy, 0,
//                                                SC_Static,
//                                                false, false);
//        // Create a scope with an artificial location for the body of this function.
//        ArtificialLocation AL(*this, Builder);
//        StartFunction(FD, C.VoidTy, Fn, FI, args);
//        AL.Emit();
//        
//        llvm::Type *structPtrTy = blockInfo.StructureType->getPointerTo();
//        
//        llvm::Value *src = GetAddrOfLocalVar(&srcDecl);
//        src = Builder.CreateLoad(src);
//        src = Builder.CreateBitCast(src, structPtrTy, "block");
//        
//        const BlockDecl *blockDecl = blockInfo.getBlockDecl();
//        
//        CodeGenFunction::RunCleanupsScope cleanups(*this);
//        
//        for (const auto &CI : blockDecl->captures()) {
//            const VarDecl *variable = CI.getVariable();
//            QualType type = variable->getType();
//            
//            const CGBlockInfo::Capture &capture = blockInfo.getCapture(variable);
//            if (capture.isConstant()) continue;
//            
//            BlockFieldFlags flags;
//            const CXXDestructorDecl *dtor = 0;
//            
//            bool useARCWeakDestroy = false;
//            bool useARCStrongDestroy = false;
//            
//            if (CI.isByRef()) {
//                flags = BLOCK_FIELD_IS_BYREF;
//                if (type.isObjCGCWeak())
//                    flags |= BLOCK_FIELD_IS_WEAK;
//            } else if (const CXXRecordDecl *record = type->getAsCXXRecordDecl()) {
//                if (record->hasTrivialDestructor())
//                    continue;
//                dtor = record->getDestructor();
//            } else if (type->isObjCRetainableType()) {
//                flags = BLOCK_FIELD_IS_OBJECT;
//                if (type->isBlockPointerType())
//                    flags = BLOCK_FIELD_IS_BLOCK;
//                
//                // Special rules for ARC captures.
//                if (getLangOpts().ObjCAutoRefCount) {
//                    Qualifiers qs = type.getQualifiers();
//                    
//                    // Don't generate special dispose logic for a captured object
//                    // unless it's __strong or __weak.
//                    if (!qs.hasStrongOrWeakObjCLifetime())
//                        continue;
//                    
//                    // Support __weak direct captures.
//                    if (qs.getObjCLifetime() == Qualifiers::OCL_Weak)
//                        useARCWeakDestroy = true;
//                    
//                    // Tools really want us to use objc_storeStrong here.
//                    else
//                        useARCStrongDestroy = true;
//                }
//            } else {
//                continue;
//            }
//            
//            unsigned index = capture.getIndex();
//            llvm::Value *srcField = Builder.CreateStructGEP(src, index);
//            
//            // If there's an explicit copy expression, we do that.
//            if (dtor) {
//                PushDestructorCleanup(dtor, srcField);
//                
//                // If this is a __weak capture, emit the release directly.
//            } else if (useARCWeakDestroy) {
//                EmitARCDestroyWeak(srcField);
//                
//                // Destroy strong objects with a call if requested.
//            } else if (useARCStrongDestroy) {
//                EmitARCDestroyStrong(srcField, ARCImpreciseLifetime);
//                
//                // Otherwise we call _Block_object_dispose.  It wouldn't be too
//                // hard to just emit this as a cleanup if we wanted to make sure
//                // that things were done in reverse.
//            } else {
//                llvm::Value *value = Builder.CreateLoad(srcField);
//                value = Builder.CreateBitCast(value, VoidPtrTy);
//                BuildBlockRelease(value, flags);
//            }
//        }
//        
//        cleanups.ForceCleanup();
//        
//        FinishFunction();
//        
//        return llvm::ConstantExpr::getBitCast(Fn, VoidPtrTy);
    }
    
    llvm::StructType *CodeGenFunction::EmitLambdaLiteralDescriptorStructure() const {
        llvm::Type *ty = llvm::IntegerType::getIntNTy(llvm::getGlobalContext(), sizeof(unsigned long int));
        //    struct __block_descriptor_1 {
        //        unsigned long int reserved;
        //        unsigned long int Block_size;
        //    }
        llvm::ArrayRef<llvm::Type *>elements = {
            ty,
            ty
        };
        llvm::StructType *descriptor = llvm::StructType::create(elements, "struct.__block_descriptor");
        return descriptor;
    }
    
    llvm::StructType *CodeGenFunction::EmitLambdaLiteralStructure(llvm::FunctionType *functionType, llvm::StructType *descriptorType, llvm::ArrayRef<llvm::Type *> *additional) const {
        llvm::SmallVector<llvm::Type *, 5> elements;
        elements.push_back([CGM voidType]->getPointerTo());
        elements.push_back([CGM intType]);
        elements.push_back([CGM intType]);
        elements.push_back(functionType);
        if (descriptorType == nullptr) {
            
        }
        elements.push_back(descriptorType);
        if (additional) {
            elements.append(additional->size(), *additional->data());
        }
        llvm::StructType *literal = llvm::StructType::create(elements, "struct.__block_literal");
        return literal;
    }

    llvm::Value *CodeGenFunction::EmitLambdaLiteralValue(llvm::Function *function, llvm::ArrayRef<llvm::Type *> *additional, llvm::StructType *descriptorType, CGFLambdaType lambdaType) {
        llvm::Constant *lambdaBlock = nil;
        switch (lambdaType) {
            case CGFLambdaGlobalType:
                lambdaBlock = getNSConcreteGlobalBlock();
                break;
            case CGFLambdaStackType:
                lambdaBlock = getNSConcreteStackBlock();
                break;
        }
        if (!lambdaBlock) {
            return nil;
        }
        llvm::StructType *struct_block_descriptor = EmitLambdaLiteralDescriptorStructure();
        llvm::StructType *struct_block_literal = EmitLambdaLiteralStructure(function->getFunctionType(), descriptorType ?: struct_block_descriptor, additional);
        
        
        // initialize for literal
        llvm::Constant *field[4];
        llvm::Constant *zero = llvm::Constant::getNullValue([CGM idType]);
        llvm::Constant *zeros[] = { zero, zero };
        
        field[0] = llvm::ConstantExpr::getGetElementPtr(lambdaBlock, zeros);
//        llvm::Value *block_literal = new llvm::GlobalVariable(*[CGM module], struct_block_literal, false, llvm::GlobalVariable::PrivateLinkage);
        return nil;
    }
    
    llvm::Value *CodeGenFunction::EmitBranchBlock(llvm::Function *parent, llvm::Value *check,
                                                  CodeGenModuleBranchBlockEmitter trueBB,
                                                  CodeGenModuleBranchBlockEmitter falseBB,
                                                  CodeGenModuleBranchBlockEmitter endBB) {
        llvm::Value *comp = check;
        llvm::BasicBlock *truebb = this->createBasicBlock("true", parent);
        llvm::BasicBlock *falsebb = this->createBasicBlock("false", parent);
        llvm::BasicBlock *endbb = this->createBasicBlock("end", parent);
        Builder->CreateCondBr(comp, truebb, falsebb);
        
        llvm::BasicBlock *blocks[3] = {truebb, falsebb, endbb};
        
        Builder->SetInsertPoint(truebb);
        trueBB(this, blocks);
        EmitBranch(endbb);
        
        Builder->SetInsertPoint(falsebb);
        falseBB(this, blocks);
        EmitBranch(endbb);
        
        Builder->SetInsertPoint(endbb);
        endBB(this, blocks);
        
        Builder->SetInsertPoint(endbb);
        return nil;
    }
    
    llvm::ReturnInst *CodeGenFunction::createReturn(llvm::Value *retValue, llvm::Function *func) {
        bool isRetVoid = false;
        if (retValue == nullptr && func == nullptr) {
            isRetVoid = true;
        } else if (func != nullptr && retValue != nullptr) {
            llvm::FunctionType *fty = func->getFunctionType();
            llvm::Type *retType = fty->getReturnType();
            llvm::Type *retValueType = retValue->getType();
            if (retType != retValueType) {
                // try to convert type from retValueType to retType
            }
        }
        if (isRetVoid == true) {
            return Builder->CreateRetVoid();
        }
        return Builder->CreateRet(retValue);
    }
    
    llvm::CallSite CodeGenFunction::EmitCallOrInvoke(llvm::Value *Callee,
                                    llvm::ArrayRef<llvm::Value *> Args,
                                    const llvm::Twine &Name) {
        //            llvm::BasicBlock *InvokeDest = getInvokeDest();
        llvm::BasicBlock *InvokeDest = Builder->GetInsertBlock();
        llvm::Instruction *Inst;
        if (!InvokeDest)
            Inst = Builder->CreateCall(Callee, Args, Name);
        else {
            llvm::BasicBlock *ContBB = createBasicBlock("invoke.cont");
            Inst = Builder->CreateInvoke(Callee, ContBB, InvokeDest, Args, Name);
            EmitBlock(ContBB);
        }
        
        // In ObjC ARC mode with no ObjC ARC exception safety, tell the ARC
        // optimizer it can aggressively ignore unwind edges.
        //            if (CGM.getLangOpts().ObjCAutoRefCount)
        //                AddObjCARCExceptionMetadata(Inst);
        
        return Inst;
    }
    
    llvm::Constant *CodeGenFunction::EmitCheckTypeDescriptor(llvm::Type *T) {
        // Only emit each type's descriptor once.
        if (llvm::Constant *C = this->getTypeDescriptor(T))
            return C;
        
        uint16_t TypeKind = -1;
        uint16_t TypeInfo = 0;
        
        if (T->isIntegerTy()) {
            llvm::IntegerType *intType = llvm::dyn_cast<llvm::IntegerType>(T);
            TypeKind = 0;
            TypeInfo = (llvm::Log2_32(intType->getBitWidth()) << 1) |
            (intType->isAggregateType() ? 1 : 0);
        } else if (T->isFloatingPointTy()) {
            TypeKind = 1;
            TypeInfo = T->getScalarSizeInBits();
        }
        
        llvm::Constant *Components[] = {
            Builder->getInt16(TypeKind), Builder->getInt16(TypeInfo),
            llvm::ConstantDataArray::getAllOnesValue(T)
        };
        llvm::Constant *Descriptor = llvm::ConstantStruct::getAnon(Components);
        
        llvm::GlobalVariable *GV =
        new llvm::GlobalVariable(*[CGM module], Descriptor->getType(),
                                 /*isConstant=*/true,
                                 llvm::GlobalVariable::PrivateLinkage,
                                 Descriptor);
        GV->setUnnamedAddr(true);
        
        // Remember the descriptor for this type.
        this->setTypeDescriptor(T, GV);
        
        return GV;
    }
    
    /// Produce the code to do a objc_autoreleasepool_push.
    ///   call i8* \@objc_autoreleasePoolPush(void)
    llvm::Value *CodeGenFunction::EmitObjCAutoreleasePoolPush() {
        llvm::Constant *&fn = getRREntrypoints().objc_autoreleasePoolPush;
        if (!fn) {
            llvm::FunctionType *fnType = llvm::FunctionType::get([CGM idType], false);
            fn = createARCRuntimeFunction(CGM, fnType, "objc_autoreleasePoolPush");
        }
        
        return EmitNounwindRuntimeCall(fn);
    }
    
    /// Produce the code to do a primitive release.
    ///   call void \@objc_autoreleasePoolPop(i8* %ptr)
    void CodeGenFunction::EmitObjCAutoreleasePoolPop(llvm::Value *value) {
        assert(value->getType() == [CGM idType]);
        
        llvm::Constant *&fn = getRREntrypoints().objc_autoreleasePoolPop;
        if (!fn) {
            llvm::FunctionType *fnType =
            llvm::FunctionType::get(Builder->getVoidTy(), [CGM idType], false);
            
            // We don't want to use a weak import here; instead we should not
            // fall into this path.
            fn = createARCRuntimeFunction(CGM, fnType, "objc_autoreleasePoolPop");
        }
        
        // objc_autoreleasePoolPop can throw.
        EmitNounwindRuntimeCall(fn, value);
    }
}

