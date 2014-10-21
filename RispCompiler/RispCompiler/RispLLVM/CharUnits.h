//
//  CharUnits.h
//  RispCompiler
//
//  Created by closure on 9/3/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef __RispCompiler__CharUnits__
#define __RispCompiler__CharUnits__


#include "llvm/ADT/DenseMapInfo.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/Support/MathExtras.h"

namespace RispLLVM {
    
    /// CharUnits - This is an opaque type for sizes expressed in character units.
    /// Instances of this type represent a quantity as a multiple of the size
    /// of the standard C type, char, on the target architecture. As an opaque
    /// type, CharUnits protects you from accidentally combining operations on
    /// quantities in bit units and character units.
    ///
    /// In both C and C++, an object of type 'char', 'signed char', or 'unsigned
    /// char' occupies exactly one byte, so 'character unit' and 'byte' refer to
    /// the same quantity of storage. However, we use the term 'character unit'
    /// rather than 'byte' to avoid an implication that a character unit is
    /// exactly 8 bits.
    ///
    /// For portability, never assume that a target character is 8 bits wide. Use
    /// CharUnit values wherever you calculate sizes, offsets, or alignments
    /// in character units.
    class CharUnits {
    public:
        typedef int64_t QuantityType;
        
    private:
        QuantityType Quantity;
        
        explicit CharUnits(QuantityType C) : Quantity(C) {}
        
    public:
        
        /// CharUnits - A default constructor.
        CharUnits() : Quantity(0) {}
        
        /// Zero - Construct a CharUnits quantity of zero.
        static CharUnits Zero() {
            return CharUnits(0);
        }
        
        /// One - Construct a CharUnits quantity of one.
        static CharUnits One() {
            return CharUnits(1);
        }
        
        /// fromQuantity - Construct a CharUnits quantity from a raw integer type.
        static CharUnits fromQuantity(QuantityType Quantity) {
            return CharUnits(Quantity);
        }
        
        // Compound assignment.
        CharUnits& operator+= (const CharUnits &Other) {
            Quantity += Other.Quantity;
            return *this;
        }
        CharUnits& operator++ () {
            ++Quantity;
            return *this;
        }
        CharUnits operator++ (int) {
            return CharUnits(Quantity++);
        }
        CharUnits& operator-= (const CharUnits &Other) {
            Quantity -= Other.Quantity;
            return *this;
        }
        CharUnits& operator-- () {
            --Quantity;
            return *this;
        }
        CharUnits operator-- (int) {
            return CharUnits(Quantity--);
        }
        
        // Comparison operators.
        bool operator== (const CharUnits &Other) const {
            return Quantity == Other.Quantity;
        }
        bool operator!= (const CharUnits &Other) const {
            return Quantity != Other.Quantity;
        }
        
        // Relational operators.
        bool operator<  (const CharUnits &Other) const {
            return Quantity <  Other.Quantity;
        }
        bool operator<= (const CharUnits &Other) const {
            return Quantity <= Other.Quantity;
        }
        bool operator>  (const CharUnits &Other) const {
            return Quantity >  Other.Quantity;
        }
        bool operator>= (const CharUnits &Other) const {
            return Quantity >= Other.Quantity;
        }
        
        // Other predicates.
        
        /// isZero - Test whether the quantity equals zero.
        bool isZero() const     { return Quantity == 0; }
        
        /// isOne - Test whether the quantity equals one.
        bool isOne() const      { return Quantity == 1; }
        
        /// isPositive - Test whether the quantity is greater than zero.
        bool isPositive() const { return Quantity  > 0; }
        
        /// isNegative - Test whether the quantity is less than zero.
        bool isNegative() const { return Quantity  < 0; }
        
        /// isPowerOfTwo - Test whether the quantity is a power of two.
        /// Zero is not a power of two.
        bool isPowerOfTwo() const {
            return (Quantity & -Quantity) == Quantity;
        }
        
        // Arithmetic operators.
        CharUnits operator* (QuantityType N) const {
            return CharUnits(Quantity * N);
        }
        CharUnits operator/ (QuantityType N) const {
            return CharUnits(Quantity / N);
        }
        QuantityType operator/ (const CharUnits &Other) const {
            return Quantity / Other.Quantity;
        }
        CharUnits operator% (QuantityType N) const {
            return CharUnits(Quantity % N);
        }
        QuantityType operator% (const CharUnits &Other) const {
            return Quantity % Other.Quantity;
        }
        CharUnits operator+ (const CharUnits &Other) const {
            return CharUnits(Quantity + Other.Quantity);
        }
        CharUnits operator- (const CharUnits &Other) const {
            return CharUnits(Quantity - Other.Quantity);
        }
        CharUnits operator- () const {
            return CharUnits(-Quantity);
        }
        
        
        // Conversions.
        
        /// getQuantity - Get the raw integer representation of this quantity.
        QuantityType getQuantity() const { return Quantity; }
        
        /// RoundUpToAlignment - Returns the next integer (mod 2**64) that is
        /// greater than or equal to this quantity and is a multiple of \p Align.
        /// Align must be non-zero.
        CharUnits RoundUpToAlignment(const CharUnits &Align) const {
            return CharUnits(llvm::RoundUpToAlignment(Quantity,
                                                      Align.Quantity));
        }
        
        /// Given that this is a non-zero alignment value, what is the
        /// alignment at the given offset?
        CharUnits alignmentAtOffset(CharUnits offset) {
            return CharUnits(llvm::MinAlign(Quantity, offset.Quantity));
        }
        
        
    }; // class CharUnit
} // namespace RispLLVM

inline RispLLVM::CharUnits operator* (RispLLVM::CharUnits::QuantityType Scale,
                                   const RispLLVM::CharUnits &CU) {
    return CU * Scale;
}

namespace llvm {
    
    template<> struct DenseMapInfo<RispLLVM::CharUnits> {
        static RispLLVM::CharUnits getEmptyKey() {
            RispLLVM::CharUnits::QuantityType Quantity =
            DenseMapInfo<RispLLVM::CharUnits::QuantityType>::getEmptyKey();
            
            return RispLLVM::CharUnits::fromQuantity(Quantity);
        }
        
        static RispLLVM::CharUnits getTombstoneKey() {
            RispLLVM::CharUnits::QuantityType Quantity =
            DenseMapInfo<RispLLVM::CharUnits::QuantityType>::getTombstoneKey();
            
            return RispLLVM::CharUnits::fromQuantity(Quantity);    
        }
        
        static unsigned getHashValue(const RispLLVM::CharUnits &CU) {
            RispLLVM::CharUnits::QuantityType Quantity = CU.getQuantity();
            return DenseMapInfo<RispLLVM::CharUnits::QuantityType>::getHashValue(Quantity);
        }
        
        static bool isEqual(const RispLLVM::CharUnits &LHS, 
                            const RispLLVM::CharUnits &RHS) {
            return LHS == RHS;
        }
    };
    
    template <> struct isPodLike<RispLLVM::CharUnits> {
        static const bool value = true;
    };
    
} // end namespace llvm

#endif /* defined(__RispCompiler__CharUnits__) */
