//
//  RispClosureMeta.h
//  RispCompiler
//
//  Created by closure on 9/19/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef __RispCompiler__RispClosureMeta__
#define __RispCompiler__RispClosureMeta__

#include "RispLLVMValueMeta.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/Support/raw_os_ostream.h"

namespace RispLLVM {
    class RispClosureMeta : public RispLLVMValueMeta {
    public:
        RispClosureMeta(bool valid = false) : RispLLVM::RispLLVMValueMeta("", closureType), _valid(valid) {
            
        }
        
        RispClosureMeta(llvm::Function *closureFunction, llvm::StructType *argumentType = nullptr) : RispLLVM::RispLLVMValueMeta(closureFunction->getName(), closureType), _valid(true), _closureFunction(closureFunction), _argumentType(argumentType) {
            _init();
        }
        
        bool isValid() const {
            return _valid == true;
        }
        
        llvm::StructType *getArgumentType() const {
            return _argumentType;
        }
        
        llvm::Function *getClosureFunction() const {
            return _closureFunction;
        }
        
        llvm::StringRef toString() const {
            std::string desc;
            llvm::raw_string_ostream sos(desc);
            sos << _closureFunction << "\n";
            sos << _argumentType;
            return desc;
        }
        
    private:
        void _init() {
            assert(_closureFunction != nullptr && "closure function must not be nullptr");
            if (_argumentType) return;
            assert(1 == _closureFunction->getArgumentList().size() && "closure function must have only one argument");
            llvm::PointerType *pty = llvm::dyn_cast<llvm::PointerType>(_closureFunction->getArgumentList().front().getType());
            llvm::StructType *structTy = llvm::dyn_cast<llvm::StructType>(pty->getElementType());
            assert(structTy != nullptr && "closure function argument must be a structure type");
            _argumentType = structTy;
        }
    private:
        llvm::Function *_closureFunction;
        llvm::StructType *_argumentType;
        bool _valid;
        
    };
}

#endif /* defined(__RispCompiler__RispClosureMeta__) */
