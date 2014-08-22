//
//  RispLLVMSelector.h
//  RispCompiler
//
//  Created by closure on 8/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef RispCompiler_RispLLVMSelector_h
#define RispCompiler_RispLLVMSelector_h

#import <Foundation/Foundation.h>
#include <objc/runtime.h>
#include "llvm/IR/DerivedTypes.h"
#import "__RispLLVMObjcType.h"

namespace RispLLVM {
    class Selector {
    public:
        Selector() : _selector(nil) {
            
        }
        
        Selector(SEL sel) : _selector(sel) {
            
        }
        
        Selector(SEL sel, id cls) : _selector(sel) {
            if (!_methodSingature) {
                _methodSingature = [cls methodSignatureForSelector:_selector];
            }
        }
        
        Selector(int idx) : _selector(reinterpret_cast<SEL>(idx)) {
            
        }
        
        std::string getAsString() const {
            return std::string(sel_getName(_selector));
        }
    public:
        static inline RispLLVM::Selector getEmptyMarker() {
            return Selector(-1);
        }
        
        static inline RispLLVM::Selector getTombstoneMarker() {
            return Selector(-2);
        }
        
        bool operator==(RispLLVM::Selector RHS) const {
            return sel_isEqual(_selector, RHS._selector);
        }
        
        bool isNull() const {
            return _selector == nil || _selector == reinterpret_cast<SEL>(-1) || _selector == reinterpret_cast<SEL>(-2);
        }
        
        unsigned getNumArgs() const {
            if (isNull()) {
                return 0;
            }
            return (unsigned)[_methodSingature numberOfArguments] - 2; // self, _cmd
        }
        
        const char *getReturnType() const {
            if (isNull()) {
                return 0;
            }
            return [_methodSingature methodReturnType];
        }
        
        llvm::Type *getLLVMReturnType() const {
            return [[__RispLLVMObjcType helper] llvmTypeFromObjectiveCType:getReturnType()];
        }
    private:
        SEL _selector;
        NSMethodSignature *_methodSingature;
    };
    
}
#endif
