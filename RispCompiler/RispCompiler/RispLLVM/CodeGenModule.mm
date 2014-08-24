//
//  CodeGenModule.cpp
//  Risp
//
//  Created by closure on 8/11/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#include "CodeGenModule.h"

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
    
    static void configureBlocksRuntimeObject(CodeGenFunction &CGF, llvm::Constant *C) {
//        if (!CGM.getLangOpts().BlocksRuntimeOptional) return;
        
        llvm::GlobalValue *GV = llvm::cast<llvm::GlobalValue>(C->stripPointerCasts());
        if (GV->isDeclaration() &&
            GV->getLinkage() == llvm::GlobalValue::ExternalLinkage)
            GV->setLinkage(llvm::GlobalValue::ExternalWeakLinkage);
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
        } else if (func != nullptr) {
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
}

