//
//  LanguageOptions.h
//  RispCompiler
//
//  Created by closure on 9/3/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef __RispCompiler__LanguageOptions__
#define __RispCompiler__LanguageOptions__

#include "llvm/IR/Module.h"

namespace RispLLVM {
    enum Visibility {
        /// Objects with "hidden" visibility are not seen by the dynamic
        /// linker.
        HiddenVisibility,
        
        /// Objects with "protected" visibility are seen by the dynamic
        /// linker but always dynamically resolve to an object within this
        /// shared object.
        ProtectedVisibility,
        
        /// Objects with "default" visibility are seen by the dynamic linker
        /// and act like normal objects.
        DefaultVisibility
    };
    
    struct SanitizerOptions {
#define SANITIZER(NAME, ID) unsigned ID : 1;
#include "Sanitizers.def"
        
        /// \brief Cached set of sanitizer options with all sanitizers disabled.
        static const SanitizerOptions Disabled;
    };
    
    /// Bitfields of LangOptions, split out from LangOptions in order to ensure that
    /// this large collection of bitfields is a trivial class type.
    class LangOptionsBase {
    public:
        // Define simple language options (with no accessors).
#define LANGOPT(Name, Bits, Default, Description) unsigned Name : Bits;
#define ENUM_LANGOPT(Name, Type, Bits, Default, Description)
#include "LanguageOptions.def"
        
        SanitizerOptions Sanitize;
    protected:
        // Define language options of enumeration type. These are private, and will
        // have accessors (below).
#define LANGOPT(Name, Bits, Default, Description)
#define ENUM_LANGOPT(Name, Type, Bits, Default, Description) \
unsigned Name : Bits;
#include "LanguageOptions.def"
    };
    
    class LanguageOptions : LangOptionsBase {
    private:
//        typedef unsigned long _LanguageOpt;
//        _LanguageOpt _hasGC : 1;
        
        
    public:
        enum GCMode { NonGC, GCOnly, HybridGC };
        enum StackProtectorMode { SSPOff, SSPOn, SSPStrong, SSPReq };
        
        enum SignedOverflowBehaviorTy {
            SOB_Undefined,  // Default C standard behavior.
            SOB_Defined,    // -fwrapv
            SOB_Trapping    // -ftrapv
        };
        
        enum PragmaMSPointersToMembersKind {
            PPTMK_BestCase,
            PPTMK_FullGeneralitySingleInheritance,
            PPTMK_FullGeneralityMultipleInheritance,
            PPTMK_FullGeneralityVirtualInheritance
        };
        
        enum AddrSpaceMapMangling { ASMM_Target, ASMM_On, ASMM_Off };
        
        std::string CurrentModule;
        
        LanguageOptions();
        
#define LANGOPT(Name, Bits, Default, Description)
#define ENUM_LANGOPT(Name, Type, Bits, Default, Description) \
Type get##Name() const { return static_cast<Type>(Name); } \
void set##Name(Type Value) { Name = static_cast<unsigned>(Value); }
#include "LanguageOptions.def"
//        bool getGC() const {
//            return _hasGC;
//        }
//        
//        void setGC(bool hasGC = true) {
//            _hasGC = hasGC;
//        }
        void resetNonModularOptions();
    };
}

#endif /* defined(__RispCompiler__LanguageOptions__) */
