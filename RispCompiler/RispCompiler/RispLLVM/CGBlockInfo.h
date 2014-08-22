//
//  CGBlockInfo.h
//  RispCompiler
//
//  Created by closure on 8/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef __RispCompiler__CGBlockInfo__
#define __RispCompiler__CGBlockInfo__

#include "llvm/IR/Type.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/IRBuilder.h"

using namespace llvm;
/// CGBlockInfo - Information to generate a block literal.
class CGBlockInfo {
public:
    /// Name - The name of the block, kindof.
    StringRef Name;
    
    /// The field index of 'this' within the block, if there is one.
    unsigned CXXThisIndex;
    
    class Capture {
        uintptr_t Data;
        EHScopeStack::stable_iterator Cleanup;
        
    public:
        bool isIndex() const { return (Data & 1) != 0; }
        bool isConstant() const { return !isIndex(); }
        unsigned getIndex() const { assert(isIndex()); return Data >> 1; }
        llvm::Value *getConstant() const {
            assert(isConstant());
            return reinterpret_cast<llvm::Value*>(Data);
        }
        EHScopeStack::stable_iterator getCleanup() const {
            assert(isIndex());
            return Cleanup;
        }
        void setCleanup(EHScopeStack::stable_iterator cleanup) {
            assert(isIndex());
            Cleanup = cleanup;
        }
        
        static Capture makeIndex(unsigned index) {
            Capture v;
            v.Data = (index << 1) | 1;
            return v;
        }
        
        static Capture makeConstant(llvm::Value *value) {
            Capture v;
            v.Data = reinterpret_cast<uintptr_t>(value);
            return v;
        }
    };
    
    /// CanBeGlobal - True if the block can be global, i.e. it has
    /// no non-constant captures.
    bool CanBeGlobal : 1;
    
    /// True if the block needs a custom copy or dispose function.
    bool NeedsCopyDispose : 1;
    
    /// HasCXXObject - True if the block's custom copy/dispose functions
    /// need to be run even in GC mode.
    bool HasCXXObject : 1;
    
    /// UsesStret : True if the block uses an stret return.  Mutable
    /// because it gets set later in the block-creation process.
    mutable bool UsesStret : 1;
    
    /// HasCapturedVariableLayout : True if block has captured variables
    /// and their layout meta-data has been generated.
    bool HasCapturedVariableLayout : 1;
    
    /// The mapping of allocated indexes within the block.
//    llvm::DenseMap<const VarDecl*, Capture> Captures;
    llvm::DenseMap<const VarDecl*, Capture> Captures;
    
    llvm::AllocaInst *Address;
    llvm::StructType *StructureType;
//    const BlockDecl *Block;
//    const BlockExpr *BlockExpression;
    CharUnits BlockSize;
    CharUnits BlockAlign;
    
    // Offset of the gap caused by block header having a smaller
    // alignment than the alignment of the block descriptor. This
    // is the gap offset before the first capturued field.
    CharUnits BlockHeaderForcedGapOffset;
    // Gap size caused by aligning first field after block header.
    // This could be zero if no forced alignment is required.
    CharUnits BlockHeaderForcedGapSize;
    
    /// An instruction which dominates the full-expression that the
    /// block is inside.
    llvm::Instruction *DominatingIP;
    
    /// The next block in the block-info chain.  Invalid if this block
    /// info is not part of the CGF's block-info chain, which is true
    /// if it corresponds to a global block or a block whose expression
    /// has been encountered.
    CGBlockInfo *NextBlockInfo;
    
    const Capture &getCapture(const VarDecl *var) const {
        return const_cast<CGBlockInfo*>(this)->getCapture(var);
    }
    Capture &getCapture(const VarDecl *var) {
        llvm::DenseMap<const VarDecl*, Capture>::iterator
        it = Captures.find(var);
        assert(it != Captures.end() && "no entry for variable!");
        return it->second;
    }
    
    const BlockDecl *getBlockDecl() const { return Block; }
    const BlockExpr *getBlockExpr() const {
        assert(BlockExpression);
        assert(BlockExpression->getBlockDecl() == Block);
        return BlockExpression;
    }
    
    CGBlockInfo(const BlockDecl *blockDecl, StringRef Name);
};
#endif /* defined(__RispCompiler__CGBlockInfo__) */
