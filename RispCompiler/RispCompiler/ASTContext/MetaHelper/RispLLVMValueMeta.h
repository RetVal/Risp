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
#include "llvm/Support/raw_os_ostream.h"

namespace RispLLVM {
    class RispLLVMValueMeta {
    public:
        typedef enum RispLLVMValueMetaType {
            classType = 0,
            instanceType = 1,
            selectorType = 2,
            functionType = 3,
            closureType  = 4,
            
        } RispLLVMValueMetaType;
        
        RispLLVMValueMeta(llvm::StringRef name = "", RispLLVM::RispLLVMValueMeta::RispLLVMValueMetaType type = RispLLVM::RispLLVMValueMeta::instanceType)
        : _name(name), _type(type) {
        };
        
        ~RispLLVMValueMeta() {
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
        
        bool isFunctionType() const {
            return _type == functionType;
        }
        
        bool isClosureType() const {
            return _type == closureType;
        }
        
        const llvm::StringRef getName() const {
            return _name;
        }
        
        void setIsClass(const bool flag = true) {
            _type = classType;
        }
        
        void setIsInstance(const bool flag = true) {
            _type = instanceType;
        }
        
        void setIsSelector(const bool flag = true) {
            _type = selectorType;
        }
        
        void setIsFunction(const bool flag = true) {
            _type = functionType;
        }
        
        void setIsClosure(const bool flag = true) {
            _type = closureType;
        }
        
        void setName(const llvm::StringRef name) {
            _name = name;
        }
        
        bool isValid() const {
            return _name.size() != 0;
        }
        
        void toString(std::string &desc, unsigned int iden = 0) const {
            for (unsigned int i = 0; i < iden; i++) {
                desc += "\t";
            }
            if (_name.size() != 0) {
                desc += _name;
                desc += "\n";
                for (unsigned int i = 0; i < iden; i++) {
                    desc += "\t";
                }
            }
            desc += "value meta type = ";
            switch (_type) {
                case classType:
                    desc += "class";
                    break;
                case instanceType:
                    desc += "instance";
                    break;
                case selectorType:
                    desc += "selector";
                    break;
                case functionType:
                    desc += "function";
                    break;
                case closureType:
                    desc += "closure";
                    break;
                default:
                    break;
            }
            desc += "\n";
            return;
        }
        
        void dump() const {
            std::string desc;
            toString(desc);
            llvm::errs() << desc;
        }
    public:
        typedef llvm::DenseMap<llvm::Value *, RispLLVM::RispLLVMValueMeta>RispLLVMDenseMetaMap;
    private:
        llvm::StringRef _name;
        RispLLVMValueMetaType _type;
    };
}
#endif /* defined(__RispCompiler__RispLLVMValueMeta__) */
