//
//  CGBlockInfo.h
//  RispCompiler
//
//  Created by closure on 9/3/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef __RispCompiler__CGBlockInfo__
#define __RispCompiler__CGBlockInfo__

#include "CharUnits.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/DerivedTypes.h"

namespace RispLLVM {
    class CGBlockInfo {
        
        
    public:
        
    public:
        
        bool NeedsCopyDispose;
        
        CharUnits BlockSize;
        CharUnits BlockAlign;
        
        // Offset of the gap caused by block header having a smaller
        // alignment than the alignment of the block descriptor. This
        // is the gap offset before the first capturued field.
        CharUnits BlockHeaderForcedGapOffset;
        // Gap size caused by aligning first field after block header.
        // This could be zero if no forced alignment is required.
        CharUnits BlockHeaderForcedGapSize;

        
        llvm::AllocaInst *Address;
        llvm::StructType *StructureType;
    };
}

#endif /* defined(__RispCompiler__CGBlockInfo__) */
