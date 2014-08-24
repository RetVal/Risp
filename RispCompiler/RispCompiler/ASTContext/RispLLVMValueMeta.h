//
//  RispLLVMValueMeta.h
//  RispCompiler
//
//  Created by closure on 8/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef __RispCompiler__RispLLVMValueMeta__
#define __RispCompiler__RispLLVMValueMeta__
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/IR/Value.h"
#include "RispLLVMDenseMap.h"

namespace RispLLVM {
    class RispLLVMValueMeta {
    public:
        typedef enum RispLLVMValueMetaType {
            classType = 0,
            instanceType = 1,
            selectorType = 2
        } RispLLVMValueMetaType;
        
        RispLLVMValueMeta(llvm::StringRef className = "", RispLLVM::RispLLVMValueMeta::RispLLVMValueMetaType type = RispLLVM::RispLLVMValueMeta::instanceType)
        : _className(className), _type(classType) {
//            printf("RispLLVMValueMeta(%s(%d)) alloc %p\n", _className.str().c_str(), _type, this);
        };
        
        ~RispLLVMValueMeta() {
//            printf("RispLLVMValueMeta(%s(%d)) dealloc %p\n", _className.str().c_str(), _type, this);
        }
        
    public:
        bool isClassType() const {
            return _type == classType;
        }
        
        bool isInstanceType() const {
            return _type == instanceType;
        }
        
        bool isSelectorType() const {
            return _type == selectorType;
        }
        
        const llvm::StringRef getClassName() const {
            return _className;
        }
        
        void setIsClass(const bool flag) {
            _type = classType;
        }
        
        void setIsInstance(const bool flag) {
            _type = instanceType;
        }
        
        void setIsSelector(const bool flag) {
            _type = selectorType;
        }
        
        void setClassName(const llvm::StringRef className) {
            _className = className;
        }
        
        bool isValid() const {
            return _className.size() != 0;
        }
    public:
        typedef RispLLVM::RispLLVMDenseMap<llvm::Value *, RispLLVM::RispLLVMValueMeta>RispLLVMDenseMetaMap;
    private:
        llvm::StringRef _className;
        RispLLVMValueMetaType _type;
    };
}
#endif /* defined(__RispCompiler__RispLLVMValueMeta__) */
