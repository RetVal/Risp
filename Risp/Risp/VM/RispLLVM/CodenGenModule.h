//
//  CodenGenModule.h
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
        llvm::IRBuilder<> Builder;
        __RispLLVMFoundation *CGM;
        
        llvm::DenseMap<llvm::Type *, llvm::Constant *> TypeDescriptorMap;
        
        typedef std::pair<llvm::Value *, llvm::Value *> ComplexPairTy;
        
    public:
        CodeGenFunction(__RispLLVMFoundation *cgm)
        : CGM(cgm), VMContext (*[cgm llvmContext]), Builder(*[cgm builder]) {
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
        
        void EmitBlock(llvm::BasicBlock *BB, bool IsFinished = false) {
            llvm::BasicBlock *CurBB = Builder.GetInsertBlock();
            
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
            Builder.SetInsertPoint(BB);
        }
        
        void EmitBranch(llvm::BasicBlock *Target) {
            // Emit a branch from the current block to the target one if this
            // was a real block.  If this was just a fall-through block after a
            // terminator, don't emit it.
            llvm::BasicBlock *CurBB = Builder.GetInsertBlock();
            
            if (!CurBB || CurBB->getTerminator()) {
                // If there is no insert point or the previous block is already
                // terminated, don't touch it.
            } else {
                // Otherwise, create a fall-through branch.
                Builder.CreateBr(Target);
            }
            
            Builder.ClearInsertionPoint();
        }
        
        //        void AddObjCARCExceptionMetadata(llvm::Instruction *Inst) {
        //            if (CGM.getCodeGenOpts().OptimizationLevel != 0 &&
        //                !CGM.getCodeGenOpts().ObjCAutoRefCountExceptions)
        //                Inst->setMetadata("clang.arc.no_objc_arc_exceptions",
        //                                  CGM.getNoObjCARCExceptionsMetadata());
        //        }
        //
        /// Emits a call to the given no-arguments nounwind runtime function.
        llvm::CallInst * EmitNounwindRuntimeCall(llvm::Value *callee,
                                                 const llvm::Twine &name) {
            return EmitNounwindRuntimeCall(callee, llvm::ArrayRef<llvm::Value*>(), name);
        }
        
        /// Emits a call to the given nounwind runtime function.
        llvm::CallInst * EmitNounwindRuntimeCall(llvm::Value *callee,
                                                 llvm::ArrayRef<llvm::Value*> args,
                                                 const llvm::Twine &name) {
            llvm::CallInst *call = EmitRuntimeCall(callee, args, name);
            call->setDoesNotThrow();
            return call;
        }
        
        /// Emits a simple call (never an invoke) to the given no-arguments
        /// runtime function.
        llvm::CallInst * EmitRuntimeCall(llvm::Value *callee,
                                         const llvm::Twine &name) {
            return EmitRuntimeCall(callee, llvm::ArrayRef<llvm::Value*>(), name);
        }
        
        /// Emits a simple call (never an invoke) to the given runtime
        /// function.
        llvm::CallInst * EmitRuntimeCall(llvm::Value *callee,
                                         llvm::ArrayRef<llvm::Value*> args,
                                         const llvm::Twine &name) {
            llvm::CallInst *call = Builder.CreateCall(callee, args, name);
            call->setCallingConv([[CGM targetCodeGenInfo] runtimeCC]);
            return call;
        }
        
        /// Emits a call or invoke to the given noreturn runtime function.
        void EmitNoreturnRuntimeCallOrInvoke(llvm::Value *callee,
                                             llvm::ArrayRef<llvm::Value*> args) {
            //            if (getInvokeDest()) {
            //                llvm::InvokeInst *invoke =
            //                Builder.CreateInvoke(callee,
            //                                     getUnreachableBlock(),
            //                                     getInvokeDest(),
            //                                     args);
            //                invoke->setDoesNotReturn();
            //                invoke->setCallingConv([[CGM targetCodeGenInfo] runtimeCC]);
            //            } else {
            //                llvm::CallInst *call = Builder.CreateCall(callee, args);
            //                call->setDoesNotReturn();
            //                call->setCallingConv([[CGM targetCodeGenInfo] runtimeCC]);
            //                Builder.CreateUnreachable();
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
        
        /// Emits a call or invoke instruction to the given function, depending
        /// on the current state of the EH stack.
        llvm::CallSite EmitCallOrInvoke(llvm::Value *Callee,
                                        llvm::ArrayRef<llvm::Value *> Args,
                                        const llvm::Twine &Name) {
            //            llvm::BasicBlock *InvokeDest = getInvokeDest();
            llvm::BasicBlock *InvokeDest = Builder.GetInsertBlock();
            llvm::Instruction *Inst;
            if (!InvokeDest)
                Inst = Builder.CreateCall(Callee, Args, Name);
            else {
                llvm::BasicBlock *ContBB = createBasicBlock("invoke.cont");
                Inst = Builder.CreateInvoke(Callee, ContBB, InvokeDest, Args, Name);
                EmitBlock(ContBB);
            }
            
            // In ObjC ARC mode with no ObjC ARC exception safety, tell the ARC
            // optimizer it can aggressively ignore unwind edges.
            //            if (CGM.getLangOpts().ObjCAutoRefCount)
            //                AddObjCARCExceptionMetadata(Inst);
            
            return Inst;
        }
        
        llvm::Constant *getTypeDescriptor(llvm::Type *T) {
            return TypeDescriptorMap[T];
        }
        
        void setTypeDescriptor(llvm::Type *T, llvm::GlobalVariable *GV) {
            TypeDescriptorMap[T] = GV;
        }
        
        llvm::Constant *EmitCheckTypeDescriptor(llvm::Type *T) {
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
                Builder.getInt16(TypeKind), Builder.getInt16(TypeInfo),
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
        
        
        //        void EmitNullInitialization(llvm::Value *DestPtr, llvm::Type *Ty) {
        //            // Ignore empty classes in C++.
        ////            if (getLangOpts().CPlusPlus) {
        ////                if (const RecordType *RT = Ty->getAs<RecordType>()) {
        ////                    if (cast<CXXRecordDecl>(RT->getDecl())->isEmpty())
        ////                        return;
        ////                }
        ////            }
        //
        //            // Cast the dest ptr to the appropriate i8 pointer type.
        //            unsigned DestAS =
        //            cast<llvm::PointerType>(DestPtr->getType())->getAddressSpace();
        //            llvm::Type *BP = Builder.getInt8PtrTy(DestAS);
        //            if (DestPtr->getType() != BP)
        //                DestPtr = Builder.CreateBitCast(DestPtr, BP);
        //
        //            // Get size and alignment info for this aggregate.
        //            std::pair<CharUnits, CharUnits> TypeInfo =
        //            getContext().getTypeInfoInChars(Ty);
        //            CharUnits Size = TypeInfo.first;
        //            CharUnits Align = TypeInfo.second;
        //
        //            llvm::Value *SizeVal;
        //            const VariableArrayType *vla;
        //
        //            // Don't bother emitting a zero-byte memset.
        //            if (Size.isZero()) {
        //                // But note that getTypeInfo returns 0 for a VLA.
        //                if (const VariableArrayType *vlaType =
        //                    dyn_cast_or_null<VariableArrayType>(
        //                                                        getContext().getAsArrayType(Ty))) {
        //                        QualType eltType;
        //                        llvm::Value *numElts;
        //                        std::tie(numElts, eltType) = getVLASize(vlaType);
        //
        //                        SizeVal = numElts;
        //                        CharUnits eltSize = getContext().getTypeSizeInChars(eltType);
        //                        if (!eltSize.isOne())
        //                            SizeVal = Builder.CreateNUWMul(SizeVal, CGM.getSize(eltSize));
        //                        vla = vlaType;
        //                    } else {
        //                        return;
        //                    }
        //            } else {
        //                SizeVal = CGM.getSize(Size);
        //                vla = 0;
        //            }
        //
        //            // If the type contains a pointer to data member we can't memset it to zero.
        //            // Instead, create a null constant and copy it to the destination.
        //            // TODO: there are other patterns besides zero that we can usefully memset,
        //            // like -1, which happens to be the pattern used by member-pointers.
        //            if (!CGM.getTypes().isZeroInitializable(Ty)) {
        //                // For a VLA, emit a single element, then splat that over the VLA.
        //                if (vla) Ty = getContext().getBaseElementType(vla);
        //
        //                llvm::Constant *NullConstant = CGM.EmitNullConstant(Ty);
        //
        //                llvm::GlobalVariable *NullVariable =
        //                new llvm::GlobalVariable(CGM.getModule(), NullConstant->getType(),
        //                                         /*isConstant=*/true,
        //                                         llvm::GlobalVariable::PrivateLinkage,
        //                                         NullConstant, Twine());
        //                llvm::Value *SrcPtr =
        //                Builder.CreateBitCast(NullVariable, Builder.getInt8PtrTy());
        //
        //                if (vla) return emitNonZeroVLAInit(*this, Ty, DestPtr, SrcPtr, SizeVal);
        //
        //                // Get and call the appropriate llvm.memcpy overload.
        //                Builder.CreateMemCpy(DestPtr, SrcPtr, SizeVal, Align.getQuantity(), false);
        //                return;
        //            }
        //
        //            // Otherwise, just memset the whole thing to zero.  This is legal
        //            // because in LLVM, all default initializers (other than the ones we just
        //            // handled above) are guaranteed to have a bit pattern of all zeros.
        //            Builder.CreateMemSet(DestPtr, Builder.getInt8(0), SizeVal,
        //                                 Align.getQuantity(), false);
        //
        //        }
        
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
            llvm::Value *isNull = CGF.Builder.CreateIsNull(receiver);
            CGF.Builder.CreateCondBr(isNull, NullBB, callBB);
            
            // Otherwise, start performing the call.
            CGF.EmitBlock(callBB);
        }
        
        /// Complete the null-return operation.  It is valid to call this
        /// regardless of whether 'init' has been called.
        //        RValue complete(CodeGenFunction &CGF, RValue result, llvm::Type *resultType,
        //                        const CallArgList &CallArgs,
        //                        const ObjCMethodDecl *Method) {
        //            // If we never had to do a null-check, just use the raw result.
        //            if (!NullBB) return result;
        //
        //            // The continuation block.  This will be left null if we don't have an
        //            // IP, which can happen if the method we're calling is marked noreturn.
        //            llvm::BasicBlock *contBB = 0;
        //
        //            // Finish the call path.
        //            llvm::BasicBlock *callBB = CGF.Builder.GetInsertBlock();
        //            if (callBB) {
        //                contBB = CGF.createBasicBlock("msgSend.cont");
        //                CGF.Builder.CreateBr(contBB);
        //            }
        //
        //            // Okay, start emitting the null-receiver block.
        //            CGF.EmitBlock(NullBB);
        //
        //            // Release any consumed arguments we've got.
        //            if (Method) {
        //                CallArgList::const_iterator I = CallArgs.begin();
        //                for (ObjCMethodDecl::param_const_iterator i = Method->param_begin(),
        //                     e = Method->param_end(); i != e; ++i, ++I) {
        //                    const ParmVarDecl *ParamDecl = (*i);
        //                    if (ParamDecl->hasAttr<NSConsumedAttr>()) {
        //                        RValue RV = I->RV;
        //                        assert(RV.isScalar() &&
        //                               "NullReturnState::complete - arg not on object");
        //                        CGF.EmitARCRelease(RV.getScalarVal(), ARCImpreciseLifetime);
        //                    }
        //                }
        //            }
        //
        //            // The phi code below assumes that we haven't needed any control flow yet.
        //            assert(CGF.Builder.GetInsertBlock() == NullBB);
        //
        //            // If we've got a void return, just jump to the continuation block.
        //            if (result.isScalar() && resultType->isVoidTy()) {
        //                // No jumps required if the message-send was noreturn.
        //                if (contBB) CGF.EmitBlock(contBB);
        //                return result;
        //            }
        //
        //            // If we've got a scalar return, build a phi.
        //            if (result.isScalar()) {
        //                // Derive the null-initialization value.
        //                llvm::Constant *null = [CGF.CGM emitNullConstant:resultType];
        //
        //                // If no join is necessary, just flow out.
        //                if (!contBB) return RValue::get(null);
        //
        //                // Otherwise, build a phi.
        //                CGF.EmitBlock(contBB);
        //                llvm::PHINode *phi = CGF.Builder.CreatePHI(null->getType(), 2);
        //                phi->addIncoming(result.getScalarVal(), callBB);
        //                phi->addIncoming(null, NullBB);
        //                return RValue::get(phi);
        //            }
        //
        //            // If we've got an aggregate return, null the buffer out.
        //            // FIXME: maybe we should be doing things differently for all the
        //            // cases where the ABI has us returning (1) non-agg values in
        //            // memory or (2) agg values in registers.
        //            if (result.isAggregate()) {
        //                assert(result.isAggregate() && "null init of non-aggregate result?");
        //                CGF.EmitNullInitialization(result.getAggregateAddr(), resultType);
        //                if (contBB) CGF.EmitBlock(contBB);
        //                return result;
        //            }
        //
        //            // Complex types.
        //            CGF.EmitBlock(contBB);
        //            CodeGenFunction::ComplexPairTy callResult = result.getComplexVal();
        //
        //            // Find the scalar type and its zero value.
        //            llvm::Type *scalarTy = callResult.first->getType();
        //            llvm::Constant *scalarZero = llvm::Constant::getNullValue(scalarTy);
        //
        //            // Build phis for both coordinates.
        //            llvm::PHINode *real = CGF.Builder.CreatePHI(scalarTy, 2);
        //            real->addIncoming(callResult.first, callBB);
        //            real->addIncoming(scalarZero, NullBB);
        //            llvm::PHINode *imag = CGF.Builder.CreatePHI(scalarTy, 2);
        //            imag->addIncoming(callResult.second, callBB);
        //            imag->addIncoming(scalarZero, NullBB);
        //            return RValue::getComplex(real, imag);
        //        }
    };
}

#include "__RispLLVMFoundation+Context.h"

#endif /* defined(__Risp__CodenGenModule__) */
