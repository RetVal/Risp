//
//  __RispLLVMTypeConverter.m
//  Risp
//
//  Created by closure on 8/10/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "__RispLLVMTypeConverter.h"
#import "__RispLLVMFoundation.h"
#include "CodenGenModule.h"

namespace RispLLVM {
    enum FloatingRank {
        HalfRank, FloatRank, DoubleRank, LongDoubleRank
    };
    
    static FloatingRank getFloatingRank(llvm::Type *T) {
        if (T->isStructTy()) {
            if (T->getStructNumElements() == 2 && T->getStructElementType(0) == T->getStructElementType(1) &&
                T->getStructElementType(0)->isFloatingPointTy()) {
                // complex
                return getFloatingRank(T->getStructElementType(0));
            }
        }
        assert(T->isFloatingPointTy() && "getFloatingRank(): not a floating type");
        switch (T->getTypeID()) {
            default: llvm_unreachable("getFloatingRank(): not a floating type");
            case llvm::Type::HalfTyID:       return HalfRank;
            case llvm::Type::FloatTyID:      return FloatRank;
            case llvm::Type::DoubleTyID:     return DoubleRank;
            case llvm::Type::FP128TyID:      return LongDoubleRank;
        }
    }
    
    static int getFloatingTypeOrder(llvm::Type *LHS, llvm::Type *RHS) {
        FloatingRank LHSR = getFloatingRank(LHS);
        FloatingRank RHSR = getFloatingRank(RHS);
        
        if (LHSR == RHSR)
            return 0;
        if (LHSR > RHSR)
            return 1;
        return -1;
    }    
}

@interface __RispLLVMTypeConverter () {
    
}
+ (void)_emitfloatConversionCheck:(llvm::Value *)OrigSrc src:(llvm::Value *)src type:(llvm::Type *)dstType CGM:(__RispLLVMFoundation *)CGM;
@end

@implementation __RispLLVMTypeConverter
+ (const llvm::fltSemantics*)floatTypeSemantics:(llvm::Type *)dstType CGM:(__RispLLVMFoundation *)CGM {
    if (dstType->isFloatTy()) return [[CGM targetCodeGenInfo] halfFormat];
    else if (dstType->isFloatTy()) return [[CGM targetCodeGenInfo] floatFormat];
    else if (dstType->isDoubleTy()) return [[CGM targetCodeGenInfo] doubleFormat];
    else if (dstType->isDoubleTy()) return [[CGM targetCodeGenInfo] longDoubleFormat];
    assert("Not a floating point type!");
    return nil;
}

+ (void)_emitfloatConversionCheck:(llvm::Value *)OrigSrc src:(llvm::Value *)src type:(llvm::Type *)dstType CGM:(__RispLLVMFoundation *)CGM {
    using llvm::APFloat;
    using llvm::APSInt;
    llvm::Type *srcTy = src->getType();
    llvm::Value *check = nullptr;
    if (llvm::IntegerType *intType = llvm::dyn_cast<llvm::IntegerType>(srcTy)) {
        assert(dstType->isFloatingPointTy());
        bool srcIsUnsigned = srcTy->isAggregateType();
        APFloat largestFloat = APFloat::getLargest(*[self floatTypeSemantics:dstType CGM:CGM]);
        APSInt largestInt(intType->getBitWidth(), srcIsUnsigned);
        bool isExact;
        if (largestFloat.convertToInteger(largestInt, APFloat::rmTowardZero, &isExact) != APFloat::opOK) {
            return;
        }
        llvm::Value *max = llvm::ConstantInt::get(*[CGM llvmContext], largestInt);
        if (srcIsUnsigned) {
            check = [CGM builder]->CreateICmpULE(src, max);
        } else {
            llvm::Value *min = llvm::ConstantInt::get(*[CGM llvmContext], -largestInt);
            llvm::Value *ge = [CGM builder]->CreateICmpSGE(src, min);
            llvm::Value *le = [CGM builder]->CreateICmpSLE(src, max);
            check = [CGM builder]->CreateAnd(ge, le);
        }
    } else {
        const llvm::fltSemantics *srcSema = [self floatTypeSemantics:srcTy CGM:CGM];
        if (llvm::isa<llvm::IntegerType>(dstType)) {
            llvm::IntegerType *ity = llvm::dyn_cast<llvm::IntegerType>(dstType);
            unsigned width = ity->getBitWidth();
            bool Unsigned = dstType->isAggregateType();
            APSInt min = APSInt::getMinValue(width, Unsigned);
            APFloat minSrc(*srcSema, APFloat::uninitialized);
            if(minSrc.convertFromAPInt(min, !Unsigned, APFloat::rmTowardZero) &
               APFloat::opOverflow) {
                minSrc = APFloat::getInf(*srcSema, true);
            } else {
                minSrc.subtract(APFloat(*srcSema, 1), APFloat::rmTowardNegative);
            }
            APSInt max = APSInt::getMaxValue(width, Unsigned);
            APFloat maxSrc(*srcSema, APFloat::uninitialized);
            if (maxSrc.convertFromAPInt(max, !Unsigned, APFloat::rmTowardZero) & APFloat::opOverflow) {
                maxSrc = APFloat::getInf(*srcSema, false);
            } else {
                maxSrc.add(APFloat(*srcSema, 1), APFloat::rmTowardPositive);
            }
            
            if (srcTy->isHalfTy()) {
                const llvm::fltSemantics *sema = [self floatTypeSemantics:srcTy CGM:CGM];
                bool isInexact;
                minSrc.convert(*sema, APFloat::rmTowardZero, &isInexact);
                maxSrc.convert(*sema, APFloat::rmTowardZero, &isInexact);
            }
            
            llvm::Value *ge = [CGM builder]->CreateFCmpOGT(src, llvm::ConstantFP::get(*[CGM llvmContext], minSrc));
            llvm::Value *le = [CGM builder]->CreateFCmpOLT(src, llvm::ConstantFP::get(*[CGM llvmContext], maxSrc));
            check = [CGM builder]->CreateAnd(ge, le);
        } else {
            if (RispLLVM::getFloatingTypeOrder(srcTy, dstType)) {
                return;
            }
            assert(!srcTy->isHalfTy() &&
                   "should not check conversion from __half, it has the lowest rank");
            const llvm::fltSemantics *dstSema = [self floatTypeSemantics:dstType CGM:CGM];
            APFloat minBad = APFloat::getLargest(*dstSema, false);
            APFloat maxBad = APFloat::getInf(*dstSema, false);
            bool isInexact;
            minBad.convert(*srcSema, APFloat::rmTowardZero, &isInexact);
            maxBad.convert(*srcSema, APFloat::rmTowardZero, &isInexact);
            llvm::Value *absSrc = [self intrinsic:llvm::Intrinsic::fabs types:src->getType() CGM:CGM];
            llvm::Value *ge = [CGM builder]->CreateFCmpOGT(absSrc, llvm::ConstantFP::get(*[CGM llvmContext], minBad));
            llvm::Value *le = [CGM builder]->CreateFCmpOLT(absSrc, llvm::ConstantFP::get(*[CGM llvmContext], maxBad));
            check = [CGM builder]->CreateNot([CGM builder]->CreateAnd(ge, le));
        }
    }
    llvm::Constant *staticArgs[] = {
        [CGM CGF].EmitCheckTypeDescriptor(srcTy),
        [CGM CGF].EmitCheckTypeDescriptor(dstType)
    };
    // emitcheck float_cast_overflow
}

+ (llvm::Function *)intrinsic:(unsigned)iid types:(llvm::ArrayRef<llvm::Type*>)types CGM:(__RispLLVMFoundation *)CGM {
    return llvm::Intrinsic::getDeclaration([CGM module], (llvm::Intrinsic::ID)iid, types);
}

+ (llvm::Value *)conversionFloatToBool:(llvm::Value *)src CGM:(__RispLLVMFoundation *)CGM {
    llvm::Value *zero = llvm::Constant::getNullValue(src->getType());
    return [CGM builder]->CreateFCmpUNE(src, zero, "tobool");
}

+ (llvm::Value *)conversionIntToBool:(llvm::Value *)src CGM:(__RispLLVMFoundation *)CGM {
    if (llvm::ZExtInst *zi = llvm::dyn_cast<llvm::ZExtInst>(src)) {
        if (zi->getOperand(0)->getType() == [CGM builder]->getInt1Ty()) {
            llvm::Value *result = zi->getOperand(0);
            if (zi->use_empty()) {
                zi->eraseFromParent();
            }
            return result;
        }
    }
    return [CGM builder]->CreateIsNotNull(src, "tobool");
}

+ (llvm::Value *)conversionPointerToBool:(llvm::Value *)src CGM:(__RispLLVMFoundation *)CGM {
    llvm::Value *zero = llvm::ConstantPointerNull::get(llvm::cast<llvm::PointerType>(src->getType()));
    return [CGM builder]->CreateICmpNE(src, zero, "tobool");
}

+ (llvm::Value *)memberPointerIsNotNull:(llvm::Value *)src CGM:(__RispLLVMFoundation *)CGM {
    llvm::Type *type = src->getType();
    
    if (!type->isFunctionTy()) {
        assert(type == [CGM ptrDiffType]);
        llvm::Value *negativeOne = llvm::Constant::getAllOnesValue(type);
        return [CGM builder]->CreateICmpNE(src, negativeOne, "memptr.tobool");
    }
    
    llvm::Value *ptr = [CGM builder]->CreateExtractValue(src, 0, "memptr.ptr");
    llvm::Constant *zero = llvm::ConstantInt::get(ptr->getType(), 0);
    llvm::Value *result = [CGM builder]->CreateICmpNE(ptr, zero, "memptr.tobool");
    
    if (NO) {
        // UseARMMethodPtrABI
        llvm::Constant *one = llvm::ConstantInt::get(ptr->getType(), 1);
        llvm::Value *adj = [CGM builder]->CreateExtractValue(src, 1, "memptr.adj");
        llvm::Value *virtualBit = [CGM builder]->CreateAnd(adj, one, "memptr.virtualbit");
        llvm::Value *isVirtual = [CGM builder]->CreateICmpNE(virtualBit, zero, "memptr.isvirtual");
        result = [CGM builder]->CreateOr(result, isVirtual);
    }
    
    return result;
}

+ (llvm::Value *)conversionToBool:(llvm::Value *)src CGM:(__RispLLVMFoundation *)CGM {
    llvm::Type *srcType = src->getType();
    if (srcType->isFloatingPointTy()) {
        return [self conversionFloatToBool:src CGM:CGM];
    }
    
    if (srcType->isPointerTy() && srcType->getPointerElementType()->isAggregateType()) {
        return [self memberPointerIsNotNull:src CGM:CGM];
    }
    
    assert((srcType->isIntegerTy() || llvm::isa<llvm::PointerType>(src->getType())) &&
           "Unknown scalar type to convert");
    if (llvm::isa<llvm::IntegerType>(srcType)) {
        return [self conversionIntToBool:src CGM:CGM];
    }
    
    assert(llvm::isa<llvm::PointerType>(srcType));
    
    return [self conversionPointerToBool:src CGM:CGM];
}

+ (llvm::Value *)conversionValue:(llvm::Value *)src toType:(llvm::Type *)type CGM:(__RispLLVMFoundation *)CGM {
    if (!src) return nil;
    if (!type) return src;
    
    llvm::Type *srcType = src->getType();
    llvm::Type *dstType = type;
    if (srcType == dstType) return src;
    if (dstType->isVoidTy()) return src;
    
    if (srcType->isHalfTy()) {
        src = [CGM builder]->CreateCall([self intrinsic:(llvm::Intrinsic::ID)llvm::Intrinsic::convert_from_fp16 types:llvm::None CGM:CGM], src);
        srcType = [CGM floatType];
    }
    
    if (dstType->isIntegerTy(1)) {
        // bool
        return src;
    }
    
    if (llvm::isa<llvm::PointerType>(dstType)) {
        if (llvm::isa<llvm::PointerType>(srcType)) {
            return [CGM builder]->CreateBitCast(src, dstType, "conv");
        }
        assert(srcType->isIntegerTy() && "Not ptr->ptr or int->ptr conversion?");
        llvm::Type *middleTy = [CGM intptrType];
        BOOL inputSigned = srcType->isAggregateType();
        llvm::IntegerType *ity = llvm::cast<llvm::IntegerType>(srcType);
        if (ity) {
            inputSigned = NO;
        }
        
        llvm::Value *intResult = [CGM builder]->CreateIntCast(src, middleTy, inputSigned, "conv");
        return [CGM builder]->CreateIntToPtr(intResult, dstType, "conv");
    }
    
    if (llvm::isa<llvm::PointerType>(srcType)) {
        assert(llvm::isa<llvm::IntegerType>(dstType) && "not ptr->int?");
        return [CGM builder]->CreatePtrToInt(src, dstType, "conv");
    }
    
    if (dstType->isVectorTy() && !srcType->isVectorTy()) {
        llvm::Type* eltType = dstType->getVectorElementType();
        llvm::Value *elt = [self conversionValue:src toType:eltType CGM:CGM];
        unsigned numElements = llvm::cast<llvm::VectorType>(dstType)->getNumElements();
        return [CGM builder]->CreateVectorSplat(numElements, elt, "splat");
    }
    
    if (llvm::isa<llvm::VectorType>(srcType) ||
        llvm::isa<llvm::VectorType>(dstType)) {
        return [CGM builder]->CreateBitCast(src, dstType, "conv");
    }
    
    llvm::Value *res = nullptr;
    llvm::Type *resType = dstType;
    
    if (srcType->isFloatingPointTy() || dstType->isFloatingPointTy()) {
        // emit float conversion check
    }
    
    if (dstType->isHalfTy()) {
        dstType = [CGM floatType];
    }
    
    if (llvm::isa<llvm::IntegerType>(srcType)) {
        BOOL inputSigned = srcType->isAggregateType();
        if (llvm::isa<llvm::IntegerType>(dstType)) {
            res = [CGM builder]->CreateIntCast(src, dstType, inputSigned, "conv");
        } else if (inputSigned) {
            res = [CGM builder]->CreateSIToFP(src, dstType, "conv");
        } else {
            res = [CGM builder]->CreateUIToFP(src, dstType, "conv");
        }
    } else if (llvm::isa<llvm::IntegerType>(dstType)) {
        assert(srcType->isFloatingPointTy() && "Unknown real conversation");
        if (dstType->isAggregateType()) {
            res = [CGM builder]->CreateFPToSI(src, dstType, "conv");
        } else {
            res = [CGM builder]->CreateFPToUI(src, dstType, "conv");
        }
    } else {
        assert(srcType->isFloatingPointTy() && dstType->isFloatingPointTy() && "Unknown real conversion");
        if (dstType->getTypeID() < srcType->getTypeID()) {
            res = [CGM builder]->CreateFPTrunc(src, dstType, "conv");
        } else {
            res = [CGM builder]->CreateFPExt(src, dstType, "conv");
        }
    }
    
    if (dstType != resType) {
        assert(resType->isIntegerTy(16) && "Only half FP requires extra conversion");
        res = [CGM builder]->CreateCall([self intrinsic:llvm::Intrinsic::convert_to_fp16 types:llvm::None CGM:CGM], res);
    }
    return res;
}
@end
