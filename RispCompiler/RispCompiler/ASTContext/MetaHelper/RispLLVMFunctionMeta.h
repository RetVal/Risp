//
//  RispLLVMFunctionMeta.h
//  RispCompiler
//
//  Created by closure on 8/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef __RispCompiler__RispLLVMFunctionMeta__
#define __RispCompiler__RispLLVMFunctionMeta__

#include "RispLLVMValueMeta.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/IR/Function.h"
#include "llvm/ADT/Hashing.h"
#include "llvm/Support/raw_os_ostream.h"

template <>
struct llvm::DenseMapInfo<llvm::StringRef> {
    static inline llvm::StringRef getEmptyKey() {
        static llvm::StringRef _empty ("");
        return _empty;
    }
    static inline llvm::StringRef getTombstoneKey() {
        static llvm::StringRef _tombstone ("");
        return _tombstone;
    }
    
    static unsigned getHashValue(llvm::StringRef str) {
        return static_cast<size_t>(llvm::hash_value(str));
    }
    
    static bool isEqual(llvm::StringRef LHS, llvm::StringRef RHS) {
        return LHS == RHS;
    }
};

namespace RispLLVM {
    
    class RispLLVMFunctionDescriptor {
    public:
        
        RispLLVMFunctionDescriptor() : _function(nullptr), _isDispatchFunction(false) {
            
        }
        
        RispLLVMFunctionDescriptor(llvm::Function *function, bool isDispatchFunction = false) : _function(function), _isDispatchFunction(isDispatchFunction) {
            
        }
        
        llvm::Function *getFunciton() const {
            return _function;
        }
        
        void setFunction(llvm::Function *function, bool isDispatchFunction = false) {
            _function = function;
            setDispatchFunction(isDispatchFunction);
        }
        
        bool isDispatchFunction() const {
            return _isDispatchFunction;
        }
        
        void setDispatchFunction(bool isDispatchFunction) {
            _isDispatchFunction = isDispatchFunction;
        }
        
        bool isValid() const {
            return _function == nullptr;
        }
        
        void toString(std::string &desc, unsigned int iden = 0) const {
            llvm::raw_string_ostream sos(desc);
            if (_function != nullptr) {
                desc += _function->getName();
                desc += " -> ";
                desc += (_isDispatchFunction ? "dispatch function" : "work function");
//                _function->print(sos);
            }
            desc += "\n";
//            for (auto i = _workFunctions.begin(), e = _workFunctions.end(); i != e; i++) {
//                for (unsigned int i = 0; i < iden; i++) {
//                    desc += "\t";
//                }
//                desc += (i->first);
//                desc += " = ";
//                (i->second)->print(sos);
//                desc += "\n";
//            }
            return;
        }
        
    private:
        llvm::Function *_function;
        bool _isDispatchFunction;
    };
    
    class RispLLVMFunctionMeta : public RispLLVMValueMeta {
    public:
        RispLLVMFunctionMeta(llvm::StringRef name) : RispLLVMValueMeta(name ,functionType) {
            
        }
        
        llvm::StringRef getName() const {
            return RispLLVMValueMeta::getName();
        }

        bool isValid() const {
            return RispLLVMValueMeta::isValid();
        }
        
        RispLLVMFunctionDescriptor getDescriptorFromName(llvm::StringRef name) {
            return _functionScope.lookup(name);
        }
        
        void setDescriptor(llvm::Function* function, RispLLVMFunctionDescriptor &descriptor) {
            setDescriptor(function->getName(), descriptor);
        }
        
        void setDescriptor(llvm::StringRef name, RispLLVMFunctionDescriptor &descriptor) {
            _functionScope[name] = descriptor;
        }
        
        void toString(std::string &desc, unsigned int iden = 0) const {
            RispLLVMValueMeta::toString(desc, 0);
            for (auto i = _functionScope.begin(), e = _functionScope.end(); i != e; i++) {
                for (unsigned int i = 0; i < iden + 1; i++) {
                    desc += "\t";
                }
                desc += (i->first);
                desc += " = ";
                (i->second).toString(desc, iden);
            }
            
            return;
        }
    private:
        llvm::DenseMap<llvm::StringRef, RispLLVM::RispLLVMFunctionDescriptor> _functionScope;
//        llvm::DenseMap<llvm::Function*, RispLLVM::RispLLVMFunctionDescriptor> _functionScopeEx;
    };
}

#endif /* defined(__RispCompiler__RispLLVMFunctionMeta__) */

