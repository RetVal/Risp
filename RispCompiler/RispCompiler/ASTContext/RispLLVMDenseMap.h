//
//  RispLLVMDenseMap.h
//  RispCompiler
//
//  Created by closure on 8/24/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef __RispCompiler__RispLLVMDenseMap__
#define __RispCompiler__RispLLVMDenseMap__

#include "llvm/ADT/DenseMap.h"

namespace RispLLVM {
    template<typename KeyT, typename ValueT>
    class RispLLVMDenseMap : public llvm::DenseMap<KeyT, ValueT> {
    public:
        RispLLVMDenseMap<KeyT, ValueT>(bool deleteKey = true, bool deleteValue = false) : _deleteKey(deleteKey), _deleteValue(deleteValue) {
            
        }
        
        ~RispLLVMDenseMap<KeyT, ValueT>() {
            for (llvm::DenseMapIterator<KeyT, ValueT> I = this->begin(), e = this->end(); I != e; ++I) {
                bool deleted = false;
//                if (_deleteKey) {
//                    delete (*I).first;
//                    deleted = true;
//                }
            }
        }
        
    public:
        bool shouldDeleteKey() const {
            return _deleteKey;
        }
        
        bool shouldDeleteValue() const {
            return _deleteValue;
        }
        
        void setShouldDeleteKey(bool flag) {
            _deleteKey = flag;
        }
        
        void setShouldDeleteValue(bool flag) {
            _deleteValue = flag;
        }
    private:
        bool _deleteKey;
        bool _deleteValue;
    };
}

#endif /* defined(__RispCompiler__RispLLVMDenseMap__) */
