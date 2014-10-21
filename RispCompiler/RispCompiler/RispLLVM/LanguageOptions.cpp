//
//  LanguageOptions.cpp
//  RispCompiler
//
//  Created by closure on 9/3/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#include "LanguageOptions.h"
using namespace RispLLVM;
const SanitizerOptions SanitizerOptions::Disabled = {};

LanguageOptions::LanguageOptions() {
#define LANGOPT(Name, Bits, Default, Description) Name = Default;
#define ENUM_LANGOPT(Name, Type, Bits, Default, Description) set##Name(Default);
#include "LanguageOptions.def"
    
    Sanitize = SanitizerOptions::Disabled;
}

void LanguageOptions::resetNonModularOptions() {
#define LANGOPT(Name, Bits, Default, Description)
#define BENIGN_LANGOPT(Name, Bits, Default, Description) Name = Default;
#define BENIGN_ENUM_LANGOPT(Name, Type, Bits, Default, Description) \
Name = Default;
#include "LanguageOptions.def"
    
    // FIXME: This should not be reset; modules can be different with different
    // sanitizer options (this affects __has_feature(address_sanitizer) etc).
    Sanitize = SanitizerOptions::Disabled;
    
    CurrentModule.clear();
}

