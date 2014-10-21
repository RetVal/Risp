//
//  __RispLLVMFoundation+Context.h
//  Risp
//
//  Created by closure on 8/11/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#include "CodeGenFunction.h"
@interface __RispLLVMFoundation (Context)
- (RispLLVM::CodeGenFunction &)CGF;
@end