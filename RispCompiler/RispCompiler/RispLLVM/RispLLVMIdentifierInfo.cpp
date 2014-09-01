//
//  RispLLVMIdentifierInfo.cpp
//  RispCompiler
//
//  Created by closure on 8/27/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#include "RispLLVMIdentifierInfo.h"

static RispLLVM::IdentifierInfo _emptyMarker("");
RispLLVM::IdentifierInfo *RispLLVM::IdentifierInfo::getEmptyMarker() {
    return &_emptyMarker;
}

RispLLVM::IdentifierInfo *RispLLVM::IdentifierInfo::getTombstoneMarker() {
    static RispLLVM::IdentifierInfo _tombstoneMarker = RispLLVM::IdentifierInfo(".");
    return &_tombstoneMarker;
}

bool RispLLVM::IdentifierInfo::operator==(const RispLLVM::IdentifierInfo *RHS) const {
    return this->_name == RHS->_name;
}

bool RispLLVM::operator<(RispLLVM::IdentifierInfo LHS, RispLLVM::IdentifierInfo RHS) {
    return LHS.getName() < RHS.getName();
}

bool RispLLVM::operator==(RispLLVM::IdentifierInfo LHS, RispLLVM::IdentifierInfo RHS) {
    if (LHS.getName().str() == "") {
        if (LHS.getName().size() == 1) {
            // what
            llvm::errs() << "";
        }
    }
    return LHS.getName() == RHS.getName();
}