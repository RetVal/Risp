//
//  RispLLVMIdentifierInfo.h
//  RispCompiler
//
//  Created by closure on 8/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef RispCompiler_RispLLVMIdentifierInfo_h
#define RispCompiler_RispLLVMIdentifierInfo_h
#include "llvm/IR/DerivedTypes.h"
#include "llvm/Support/raw_os_ostream.h"
namespace RispLLVM {
    
    class IdentifierInfo;
    
    class IdentifierInfo {

    public:
        IdentifierInfo(llvm::StringRef name) : _name(name) {
//            printf("%s %s\n", "IdentifierInfo()", _name.str().c_str());
        }
        
        static inline RispLLVM::IdentifierInfo *getEmptyMarker() {
            static RispLLVM::IdentifierInfo _emptyMarker = RispLLVM::IdentifierInfo("");
            return &_emptyMarker;
        }
        
        static inline RispLLVM::IdentifierInfo *getTombstoneMarker() {
            static RispLLVM::IdentifierInfo _tombstoneMarker = RispLLVM::IdentifierInfo(".");
            return &_tombstoneMarker;
        }
        
        ~IdentifierInfo() {
//            printf("%s %s\n", "~IdentifierInfo()", _name.str().c_str());
        }
        
        llvm::StringRef getName() const {
            return _name;
        }
        
        bool operator==(const RispLLVM::IdentifierInfo *RHS) const {
            return this->_name == RHS->_name;
        }
  
    private:
        llvm::StringRef _name;
    };
    
    inline bool operator<(RispLLVM::IdentifierInfo LHS, RispLLVM::IdentifierInfo RHS) {
        return LHS.getName() < RHS.getName();
    }
    
    inline bool operator==(RispLLVM::IdentifierInfo LHS, RispLLVM::IdentifierInfo RHS) {
        return LHS.getName() == RHS.getName();
    }
    
    class RValue {
        enum Flavor { Scalar, Complex, Aggregate };
        
        // Stores first value and flavor.
        llvm::PointerIntPair<llvm::Value *, 2, Flavor> V1;
        // Stores second value and volatility.
        llvm::PointerIntPair<llvm::Value *, 1, bool> V2;
        
    public:
        bool isScalar() const { return V1.getInt() == Scalar; }
        bool isComplex() const { return V1.getInt() == Complex; }
        bool isAggregate() const { return V1.getInt() == Aggregate; }
        
        bool isVolatileQualified() const { return V2.getInt(); }
        
        /// getScalarVal() - Return the Value* of this scalar value.
        llvm::Value *getScalarVal() const {
            assert(isScalar() && "Not a scalar!");
            return V1.getPointer();
        }
        
        /// getComplexVal - Return the real/imag components of this complex value.
        ///
        std::pair<llvm::Value *, llvm::Value *> getComplexVal() const {
            return std::make_pair(V1.getPointer(), V2.getPointer());
        }
        
        /// getAggregateAddr() - Return the Value* of the address of the aggregate.
        llvm::Value *getAggregateAddr() const {
            assert(isAggregate() && "Not an aggregate!");
            return V1.getPointer();
        }
        
        static RValue get(llvm::Value *V) {
            RValue ER;
            ER.V1.setPointer(V);
            ER.V1.setInt(Scalar);
            ER.V2.setInt(false);
            return ER;
        }
        static RValue getComplex(llvm::Value *V1, llvm::Value *V2) {
            RValue ER;
            ER.V1.setPointer(V1);
            ER.V2.setPointer(V2);
            ER.V1.setInt(Complex);
            ER.V2.setInt(false);
            return ER;
        }
        static RValue getComplex(const std::pair<llvm::Value *, llvm::Value *> &C) {
            return getComplex(C.first, C.second);
        }
        // FIXME: Aggregate rvalues need to retain information about whether they are
        // volatile or not.  Remove default to find all places that probably get this
        // wrong.
        static RValue getAggregate(llvm::Value *V, bool Volatile = false) {
            RValue ER;
            ER.V1.setPointer(V);
            ER.V1.setInt(Aggregate);
            ER.V2.setInt(Volatile);
            return ER;
        }
    };
}

#endif
