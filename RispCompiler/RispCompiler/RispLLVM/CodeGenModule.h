//
//  CodeGenModule.h
//  Risp
//
//  Created by closure on 8/11/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef __Risp__CodenGenModule__
#define __Risp__CodenGenModule__

#import "__RispLLVMFoundation.h"
#include "llvm/IR/CallSite.h"

namespace RispLLVM {
    class CodeGenFunction {
    public:
        llvm::IRBuilder<> *Builder;
        __RispLLVMFoundation *CGM;
        
        llvm::DenseMap<llvm::Type *, llvm::Constant *> TypeDescriptorMap;
        
        typedef std::pair<llvm::Value *, llvm::Value *> ComplexPairTy;
        
    public:
        CodeGenFunction(__RispLLVMFoundation *cgm)
        : CGM(cgm), VMContext (*[cgm llvmContext]), Builder([cgm builder]) {
        }
        
        llvm::LLVMContext &getLLVMContext () const {
            return VMContext;
        }
        
        llvm::BasicBlock *createBasicBlock(const llvm::Twine &name = "",
                                           llvm::Function *parent = 0,
                                           llvm::BasicBlock *before = 0) {
#ifdef NDEBUG
            return llvm::BasicBlock::Create(getLLVMContext(), "", parent, before);
#else
            return llvm::BasicBlock::Create(getLLVMContext(), name, parent, before);
#endif
        }

        typedef llvm::BasicBlock *(^CodeGenModuleBranchBlockEmitter)(CodeGenFunction *CGF, llvm::BasicBlock *blocks[3]);
        typedef enum CGFBranchBlockIdentifier {
            CGFBranchTrueBlockId = 0,
            CGFBranchFalseBlockId = 1,
            CGFBranchEndBlockId = 2
        } CGFBranchBlockIdentifier;
        
        llvm::Value *EmitBranchBlock(llvm::Function *parent, llvm::Value *check,
                                     CodeGenModuleBranchBlockEmitter trueBB,
                                     CodeGenModuleBranchBlockEmitter falseBB,
                                     CodeGenModuleBranchBlockEmitter endBB);
        
        llvm::StructType *EmitLambdaLiteralDescriptorStructure() const;
        llvm::StructType *EmitLambdaLiteralStructure(llvm::FunctionType *functionType, llvm::StructType *descriptorType = nullptr, llvm::ArrayRef<llvm::Type *> *additional = nullptr) const;
        llvm::Constant *getNSConcreteGlobalBlock();
        llvm::Constant *getNSConcreteStackBlock();
        llvm::Constant *getBlockObjectAssign();
        llvm::Constant *getBlockObjectDispose();
        
        llvm::Type *getBlockDescriptorType();
        
        /// getGenericBlockLiteralType - The type of a generic block literal.
        llvm::Type *getGenericBlockLiteralType();
        
        llvm::CallInst *EmitRuntimeCall(llvm::Value *callee,
                                        const llvm::Twine &name = "");
        llvm::CallInst *EmitRuntimeCall(llvm::Value *callee,
                                        llvm::ArrayRef<llvm::Value*> args,
                                        const llvm::Twine &name = "");
        llvm::CallInst *EmitNounwindRuntimeCall(llvm::Value *callee,
                                                const llvm::Twine &name = "");
        llvm::CallInst *EmitNounwindRuntimeCall(llvm::Value *callee,
                                                llvm::ArrayRef<llvm::Value*> args,
                                                const llvm::Twine &name = "");
        
        typedef enum CGFLambdaType {
            CGFLambdaGlobalType = 0,
            CGFLambdaStackType = 1
        }CGFLambdaType;
        
        llvm::Value *EmitLambdaLiteralValue(llvm::Function *function, llvm::ArrayRef<llvm::Type *> *additional = nullptr, llvm::StructType *descriptorType = nullptr, CGFLambdaType lambdaType = CGFLambdaGlobalType);
        
        void EmitBlock(llvm::BasicBlock *BB, bool IsFinished = false) {
            llvm::BasicBlock *CurBB = Builder->GetInsertBlock();
            
            // Fall out of the current block (if necessary).
            EmitBranch(BB);
            
            if (IsFinished && BB->use_empty()) {
                delete BB;
                return;
            }
            
            // Place the block after the current block, if possible, or else at
            // the end of the function.
            if (CurBB && CurBB->getParent())
                CurFn->getBasicBlockList().insertAfter(CurBB, BB);
            else
                CurFn->getBasicBlockList().push_back(BB);
            Builder->SetInsertPoint(BB);
        }
        
        void EmitBranch(llvm::BasicBlock *Target) {
            // Emit a branch from the current block to the target one if this
            // was a real block.  If this was just a fall-through block after a
            // terminator, don't emit it.
            llvm::BasicBlock *CurBB = Builder->GetInsertBlock();
            
            if (!CurBB || CurBB->getTerminator()) {
                // If there is no insert point or the previous block is already
                // terminated, don't touch it.
            } else {
                // Otherwise, create a fall-through branch.
                Builder->CreateBr(Target);
            }
            
            Builder->ClearInsertionPoint();
        }
        
        //        void AddObjCARCExceptionMetadata(llvm::Instruction *Inst) {
        //            if (CGM.getCodeGenOpts().OptimizationLevel != 0 &&
        //                !CGM.getCodeGenOpts().ObjCAutoRefCountExceptions)
        //                Inst->setMetadata("clang.arc.no_objc_arc_exceptions",
        //                                  CGM.getNoObjCARCExceptionsMetadata());
        //        }
        //
        /// Emits a call to the given no-arguments nounwind runtime function.

        
        /// Emits a call or invoke to the given noreturn runtime function.
        void EmitNoreturnRuntimeCallOrInvoke(llvm::Value *callee,
                                             llvm::ArrayRef<llvm::Value*> args) {
            //            if (getInvokeDest()) {
            //                llvm::InvokeInst *invoke =
            //                Builder->CreateInvoke(callee,
            //                                     getUnreachableBlock(),
            //                                     getInvokeDest(),
            //                                     args);
            //                invoke->setDoesNotReturn();
            //                invoke->setCallingConv([[CGM targetCodeGenInfo] runtimeCC]);
            //            } else {
            //                llvm::CallInst *call = Builder->CreateCall(callee, args);
            //                call->setDoesNotReturn();
            //                call->setCallingConv([[CGM targetCodeGenInfo] runtimeCC]);
            //                Builder->CreateUnreachable();
            //            }
            //            PGO.setCurrentRegionUnreachable();
        }
        
        /// Emits a call or invoke instruction to the given nullary runtime
        /// function.
        llvm::CallSite EmitRuntimeCallOrInvoke(llvm::Value *callee,
                                               const llvm::Twine &name) {
            return EmitRuntimeCallOrInvoke(callee, llvm::ArrayRef<llvm::Value*>(), name);
        }
        
        /// Emits a call or invoke instruction to the given runtime function.
        llvm::CallSite EmitRuntimeCallOrInvoke(llvm::Value *callee,
                                               llvm::ArrayRef<llvm::Value*> args,
                                               const llvm::Twine &name) {
            llvm::CallSite callSite = EmitCallOrInvoke(callee, args, name);
            callSite.setCallingConv([[CGM targetCodeGenInfo] runtimeCC]);
            return callSite;
        }
        
        llvm::CallSite EmitCallOrInvoke(llvm::Value *Callee,
                                        const llvm::Twine &Name) {
            return EmitCallOrInvoke(Callee, llvm::ArrayRef<llvm::Value *>(), Name);
        }
        
        llvm::ReturnInst *createReturn(llvm::Value *retValue, llvm::Function *func = nullptr);
        /// Emits a call or invoke instruction to the given function, depending
        /// on the current state of the EH stack.
        llvm::CallSite EmitCallOrInvoke(llvm::Value *Callee,
                                        llvm::ArrayRef<llvm::Value *> Args,
                                        const llvm::Twine &Name);
        
        llvm::Constant *getTypeDescriptor(llvm::Type *T) {
            return TypeDescriptorMap[T];
        }
        
        void setTypeDescriptor(llvm::Type *T, llvm::GlobalVariable *GV) {
            TypeDescriptorMap[T] = GV;
        }
        
        llvm::Constant *EmitCheckTypeDescriptor(llvm::Type *T);
        
        typedef struct CodeGenFunctionBlock {
            llvm::StructType *__block_literal;
            llvm::Function *__block_invoke;
            llvm::StructType *__block_description_static;
        } CodeGenFunctionBlock;
        
    public:
        llvm::Function *CurFn;
        llvm::Type *FnRetTy;
        
        void StartFunction(llvm::Type *returnType, llvm::Function *Fn) {
            CurFn = Fn;
            FnRetTy = returnType;
            
        }
        
        void FinishFunction() {
            
        }
        
    private:
        llvm::LLVMContext &VMContext;
        llvm::Constant *NSConcreteGlobalBlock;
        llvm::Constant *NSConcreteStackBlock;
        
        llvm::Constant *BlockObjectAssign;
        llvm::Constant *BlockObjectDispose;
        
        llvm::Type *BlockDescriptorType;
        llvm::Type *GenericBlockLiteralType;
    };
    
    /// A helper class for performing the null-initialization of a return
    /// value.
    struct NullReturnState {
        llvm::BasicBlock *NullBB;
        NullReturnState() : NullBB(0) {}
        
        /// Perform a null-check of the given receiver.
        void init(RispLLVM::CodeGenFunction &CGF, llvm::Value *receiver) {
            // Make blocks for the null-receiver and call edges.
            NullBB = CGF.createBasicBlock("msgSend.null-receiver");
            llvm::BasicBlock *callBB = CGF.createBasicBlock("msgSend.call");
            
            // Check for a null receiver and, if there is one, jump to the
            // null-receiver block.  There's no point in trying to avoid it:
            // we're always going to put *something* there, because otherwise
            // we shouldn't have done this null-check in the first place.
            llvm::Value *isNull = CGF.Builder->CreateIsNull(receiver);
            CGF.Builder->CreateCondBr(isNull, NullBB, callBB);
            
            // Otherwise, start performing the call.
            CGF.EmitBlock(callBB);
        }
    };
}

#include "__RispLLVMFoundation+Context.h"

#endif /* defined(__Risp__CodenGenModule__) */
