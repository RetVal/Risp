//
//  __RispLLVMTypeConverter.h
//  Risp
//
//  Created by closure on 8/10/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/ADT/APSInt.h"

@class __RispLLVMFoundation;
@interface __RispLLVMTypeConverter : NSObject
+ (llvm::Function *)intrinsic:(unsigned)iid types:(llvm::ArrayRef<llvm::Type*>)types CGM:(__RispLLVMFoundation *)CGM;
+ (llvm::Value *)conversionFloatToBool:(llvm::Value *)src CGM:(__RispLLVMFoundation *)CGM;
+ (llvm::Value *)conversionIntToBool:(llvm::Value *)src CGM:(__RispLLVMFoundation *)CGM;
+ (llvm::Value *)conversionPointerToBool:(llvm::Value *)src CGM:(__RispLLVMFoundation *)CGM;
+ (llvm::Value *)memberPointerIsNotNull:(llvm::Value *)src CGM:(__RispLLVMFoundation *)CGM;
+ (llvm::Value *)conversionToBool:(llvm::Value *)src CGM:(__RispLLVMFoundation *)CGM;
+ (llvm::Value *)conversionValue:(llvm::Value *)src toType:(llvm::Type *)type CGM:(__RispLLVMFoundation *)CGM;
@end
