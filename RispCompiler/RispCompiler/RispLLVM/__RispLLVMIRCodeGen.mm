//
//  __RispLLVMIRCodeGen.m
//  Risp
//
//  Created by closure on 8/9/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "__RispLLVMIRCodeGen.h"
#include "llvm/Support/raw_ostream.h"
@implementation __RispLLVMIRCodeGen
+ (NSString *)IRCodeFromModule:(llvm::Module *)module {
    if (!module) return nil;
    std::string content;
    llvm::raw_string_ostream sos(content);
    sos << *module;
    return [[NSString alloc] initWithUTF8String:content.c_str()];
}
@end
