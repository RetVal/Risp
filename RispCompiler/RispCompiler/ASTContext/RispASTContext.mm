//
//  RispASTContext.m
//  RispCompiler
//
//  Created by closure on 8/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispASTContext.h"
#import "__RispLLVMFoundation.h"
#import "__RispLLVMFoundation+Context.h"

#import <RispCompiler/RispScopeStack.h>
#import <RispCompiler/RispSymbolExpression+Meta.h>
#import <RispCompiler/RispNameMangling.h>
#import <RispCompiler/RispNameManglingFunctionDescriptor.h>
#import <RispCompiler/RispNameManglingArgumentsDescriptor.h>
#import <RispCompiler/RispCompilerExceptionLocation.h>

#import <RispCompiler/RispBuiltin.h>

#import "__RispLLVMFunctionHelper.h"
#include "CodeGenModule.h"
#include "RispLLVMFunctionMeta.h"

@interface RispASTContext () {
@private
    __RispLLVMFoundation *_CGM;
    RispScopeStack *_currentStack;
    llvm::DenseMap<llvm::StringRef, RispLLVM::RispLLVMFunctionMeta *> _globalFunctionScope;
    llvm::SmallVector<RispLLVM::RispLLVMFunctionMeta *, 32> _globalFunctionMetaSet;
    
    llvm::Value *_autoreleasePoolRoot;
}
- (RispLLVM::RispLLVMFunctionMeta *)metaForFunction:(llvm::Function *)function;
@end

@implementation RispSequence (IR)

- (llvm::Value *)generateCode:(RispASTContext *)context {
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::Value *RispRispSequenceClass = [CGM emitClassNamed:@"RispSequence" isWeak:NO];
    
    __block llvm::SmallVector<llvm::Value *, 16> args;
    [[self reverse] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        args.push_back((llvm::Value *)[obj generateCode:context]);
    }];
    args.push_back(llvm::ConstantPointerNull::get([CGM idType]));
    llvm::Value *ret = [CGM emitMessageCall:RispRispSequenceClass selector:@selector(listWithObjects:) arguments:args instance:[RispSequence class]];
    [[context currentStack] setMeta:RispLLVM::RispLLVMValueMeta("RispSequence") forValue:ret];
    return ret;
}

@end

@implementation RispList (IR)

- (llvm::Value *)generateCode:(RispASTContext *)context {
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::Value *RispRispListClass = [CGM emitClassNamed:@"RispList" isWeak:NO];
    
    __block llvm::SmallVector<llvm::Value *, 16> args;
    [[self reverse] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        args.push_back((llvm::Value *)[obj generateCode:context]);
    }];
    args.push_back(llvm::ConstantPointerNull::get([CGM idType]));
    llvm::Value *ret = [CGM emitMessageCall:RispRispListClass selector:@selector(listWithObjects:) arguments:args instance:[RispList class]];
    [[context currentStack] setMeta:RispLLVM::RispLLVMValueMeta("RispList") forValue:ret];
    return ret;
}

@end

@implementation RispVector (IR)

- (llvm::Value *)generateCode:(RispASTContext *)context {
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::Value *RispRispVectorClass = [CGM emitClassNamed:@"RispVector" isWeak:NO];
    
    __block llvm::SmallVector<llvm::Value *, 16> args;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        args.push_back((llvm::Value *)[obj generateCode:context]);
    }];
    args.push_back(llvm::ConstantPointerNull::get([CGM idType]));
    llvm::Value *ret = [CGM emitMessageCall:RispRispVectorClass selector:@selector(listWithObjects:) arguments:args instance:[RispVector class]];
    [[context currentStack] setMeta:RispLLVM::RispLLVMValueMeta("RispVector") forValue:ret];
    return ret;
    return nil;
}

@end

@implementation RispVectorExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    return [[self vector] generateCode:context];
}

@end

@implementation RispCharSequence (IR)

- (llvm::Value *)generateCode:(RispASTContext *)context {
    return nil;
}

@end

@implementation RispTrueExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    double fvalue = [[self value] doubleValue];
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::Value *ret = [CGM emitNSDecimalNumberLiteral:fvalue];
    [[context currentStack] setMeta:std::move(RispLLVM::RispLLVMValueMeta("NSDecimalNumber")) forValue:ret];
    return ret;
}

@end

@implementation RispFalseExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    double fvalue = [[self value] doubleValue];
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::Value *ret = [CGM emitNSDecimalNumberLiteral:fvalue];
    [[context currentStack] setMeta:std::move(RispLLVM::RispLLVMValueMeta("NSDecimalNumber")) forValue:ret];
    return ret;
}

@end

@implementation RispNumberExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    double fvalue = [[self value] doubleValue];
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::Value *ret = [CGM emitNSDecimalNumberLiteral:fvalue];
    [[context currentStack] setMeta:std::move(RispLLVM::RispLLVMValueMeta("NSDecimalNumber")) forValue:ret];
    return ret;
}

@end

@implementation RispNilExpression (IR)

+ (llvm::Value *)emitNSNullWithMeta:(RispASTContext *)context {
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::Value *ret = [CGM emitNSNull];
    [[context currentStack] setMeta:std::move(RispLLVM::RispLLVMValueMeta("NSNull")) forValue:ret];
    return ret;
}

- (void *)generateCode:(RispASTContext *)context {
    return [RispNilExpression emitNSNullWithMeta:context];
}

@end

@implementation RispStringExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    NSString *sValue = [self value];
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::Constant *str = [CGM emitObjCStringLiteral:sValue];
    [[context currentStack] setMeta:std::move(RispLLVM::RispLLVMValueMeta("NSString")) forValue:str];
    return str;
}

@end

@implementation RispSymbolExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::Value *variable = [[context currentStack] objectForKey:self];
    if (variable == nil) {
        Class cls = NSClassFromString([self stringValue]);
        if (cls) {
            RispLLVM::RispLLVMValueMeta meta = RispLLVM::RispLLVMValueMeta([[self stringValue] UTF8String], RispLLVM::RispLLVMValueMeta::classType);
            llvm::Value *llvmClass = [CGM emitClassNamed:[self stringValue] isWeak:NO];
            [[context currentStack] setMeta:std::move(meta) forValue:llvmClass];
            return llvmClass;
        } else {
            llvm::Function *function = [__RispLLVMFunctionHelper __functionWithMangling:[RispNameMangling nameMangling] fromName:[self stringValue] arguments:nil context:context];
            if (function) {
                return function;
            } else if ([[self stringValue] hasSuffix:@":"]) {
                SEL sel = NSSelectorFromString([self stringValue]);
                return [CGM emitSelector:sel isValue:NO];
            }
            [NSException raise:RispRuntimeException format:@"symbol -> %@ is nil", [self stringValue]];
        }
    }
    
    llvm::Argument *argumentOfFunc = llvm::dyn_cast<llvm::Argument>(variable);
    if (argumentOfFunc != nullptr) {
        return argumentOfFunc;
    }
    return [CGM valueForVariable:variable];
}

@end

@implementation RispSelectorExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::Value *llvmSelector = [CGM emitSelector:RispLLVM::Selector(NSSelectorFromString([self stringValue])) isValue:NO];
    [[context currentStack] setMeta:std::move(RispLLVM::RispLLVMValueMeta([[self stringValue] UTF8String], RispLLVM::RispLLVMValueMeta::selectorType)) forValue:llvmSelector];
    return llvmSelector;
}
@end

@implementation RispConstantExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    return [[self constantValue] generateCode:context];
}

@end

@implementation RispDotExpression (IR)
- (void *)generateCode:(RispASTContext *)context {
    __RispLLVMFoundation *CGM = [context CGM];
    RispBaseExpression *targetExpression = [self targetExpression];
    RispSelectorExpression *selectorExpression = [self selectorExpression];
    llvm::Value *llvmTarget = (llvm::Value *)[targetExpression generateCode:context];
    SEL selector = NSSelectorFromString([selectorExpression stringValue]);
    
    id ins = nil;
    RispLLVM::RispLLVMValueMeta metaOfTarget = [[context currentStack] metaForValue:llvmTarget];
    if (!metaOfTarget.isValid()) {
        [NSException raise:RispRuntimeException format:@"RispLLVM::RispLLVMValueMeta meta is nil"];
    }
    if (metaOfTarget.isClassType()) {
        ins = NSClassFromString(@(metaOfTarget.getName().str().c_str()));
    } else if (metaOfTarget.isInstanceType()) {
        ins = [[NSClassFromString(@(metaOfTarget.getName().str().c_str())) alloc] init];
    }
    
    llvm::SmallVector<llvm::Value *, 8> args;
    for (RispBaseExpression *expr in [self exprs]) {
        args.push_back((llvm::Value *)[expr generateCode:context]);
    }
    llvm::Value *ret = [CGM emitMessageCall:llvmTarget selector:selector arguments:args instance:ins];
    RispLLVM::Selector sel (selector, ins);
    RispLLVM::RispLLVMValueMeta meta = RispLLVM::RispLLVMValueMeta(metaOfTarget.getName());
    if (sel.returnTypeIsClass()) {
        meta.setIsClass();
    } else if (sel.returnTypeIsInstance()) {
        meta.setIsInstance();
    } else if (sel.returnTypeIsSelector()) {
        meta.setIsSelector();
    } else if (sel.returnTypeIsFunction()) {
        meta.setIsFunction();
        if (llvm::isa<llvm::CallInst>(ret)) {
            llvm::CallInst *lastCallInst = llvm::dyn_cast<llvm::CallInst>(ret);
            llvm::Function *calledFunction = lastCallInst->getCalledFunction();
            if (calledFunction != nullptr) {
                meta.setName(calledFunction->getName());
            }
        }
    }
    [[context currentStack] setMeta:std::move(meta) forValue:ret];
    return ret;
}
@end

@implementation RispDefExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::Value *variable = [CGM createVariable:[CGM idType] named:[[[self key] stringValue] UTF8String]];
    [[context currentStack] setObject:variable forKey:[self key]];
    llvm::Value *value = (llvm::Value *)[[self value] generateCode:context];
    RispLLVM::RispLLVMValueMeta meta = [[context currentStack] metaForValue:value];
    llvm::Value *ret = [CGM setValue:value forVariable:variable];
    if (meta.isValid()) {
        [[context currentStack] setMeta:std::move(meta) forValue:ret];
    }
    return ret;
}

@end

@implementation RispBodyExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    void *ret = nil;
    for (RispBaseExpression *expr in [self exprs]) {
        ret = [expr generateCode:context];
    }
    return ret;
}

@end

@implementation RispMethodExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::SmallVector<llvm::Type *, 8> argumentsTypes;
    llvm::SmallVector<llvm::StringRef, 8> argumentsNames;
    // warnning currently assume param is symbol only
    for (RispSymbolExpression *params in [self requiredParms]) {
        argumentsTypes.push_back([CGM idType]);
        argumentsNames.push_back([[params stringValue] UTF8String]);
    }
    
    [context pushStack];
    
    BOOL isVariadicArgumetns = [self isVariadic];
    llvm::FunctionType *funcType = llvm::FunctionType::get([CGM idType], argumentsTypes, isVariadicArgumetns);
    llvm::Function *func = llvm::Function::Create(funcType, llvm::GlobalVariable::ExternalLinkage, "", [CGM module]);
    [__RispLLVMCodeGenFunction setNamesForFunction:func arugmentNames:argumentsNames];
    
    // init the function arguments in stack
    for (llvm::Argument &arg : func->args()) {
        llvm::StringRef name = arg.getName();
        llvm::Value *value = &arg;
        RispSymbolExpression *symbolExpr = [[RispSymbolExpression alloc] initWithSymbol:[RispSymbol named:[NSString stringWithUTF8String:name.str().c_str()]]];
        [[context currentStack] setObject:value forKey:symbolExpr];
    }
    
    llvm::BasicBlock *savePoint = [CGM builder]->GetInsertBlock();
    [CGM builder]->SetInsertPoint([CGM CGF].createBasicBlock("entry", func));
    RispBodyExpression *bodyExpression = [self bodyExpression];
    llvm::Value *lastReturn = (llvm::Value *)[bodyExpression generateCode:context];
    llvm::Value *retValue = lastReturn;
    
    RispLLVM::RispLLVMValueMeta meta;
    
    if (lastReturn == nil) {
        retValue = [RispNilExpression emitNSNullWithMeta:context];
        meta = [[context currentStack] metaForValue:retValue];
    } else if (lastReturn->getType() != funcType->getReturnType()) {
        if (lastReturn->getType() == [CGM voidType]) {
            retValue = [RispNilExpression emitNSNullWithMeta:context];
            meta = [[context currentStack] metaForValue:retValue];
        } else {
            retValue = [CGM builder]->CreateBitCast(lastReturn, funcType->getReturnType());
            bool isLastReturnFunction = llvm::isa<llvm::Function>(lastReturn);
            if (isLastReturnFunction) {
                llvm::Function *lastReturnFunc = llvm::dyn_cast<llvm::Function>(lastReturn);
                llvm::StringRef functionName = lastReturnFunc->getName();
                meta.setName(functionName);
                meta.setIsFunction();
                
                RispLLVM::RispLLVMFunctionMeta *functionMeta = [context metaForFunction:lastReturnFunc];
                BOOL isDispatch = ![[RispNameMangling nameMangling] isManglingFunction:[NSString stringWithUTF8String:functionName.str().c_str()] context:context];
                if (isDispatch) {
                    // is dispatch function
                    RispLLVM::RispLLVMFunctionDescriptor descriptor(lastReturnFunc, true);
                    functionMeta->setDescriptor(functionName, descriptor);
                } else {
//                    RispLLVM::RispLLVMFunctionDescriptor descriptor(lastReturnFunc, false);
//                    functionMeta->setDescriptor(functionName, descriptor);
                    // is work function
                    // but currently it is not haven a name
                }
            }
        }
    }
    [CGM CGF].createReturn(retValue);
    [context popStack];
    
    [CGM builder]->SetInsertPoint(savePoint);
    [[context currentStack] setMeta:meta forValue:func];
    return func;
}

@end

@implementation RispFnExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::SmallVector<llvm::Function *, 5> functions;
    for (RispMethodExpression *method in [self methods]) {
        llvm::Function *function = (llvm::Function *)[method generateCode:context];
        RispNameManglingFunctionDescriptor *functionDescriptor = [[RispNameMangling nameMangling] methodMangling:method functionName:[[self name] stringValue]];
        function->setName([[functionDescriptor functionName] UTF8String]);
        functions.push_back(function);
    }
    
    [context pushStack];
    
    llvm::FunctionType *funcEntryType = llvm::FunctionType::get([CGM idType], {[CGM idType]}, NO);
    llvm::Function *funcEntry = llvm::Function::Create(funcEntryType, llvm::GlobalVariable::ExternalLinkage, [[[self name] stringValue] UTF8String], [CGM module]);
    [__RispLLVMCodeGenFunction setNamesForFunction:funcEntry arugmentNames:{"vec"}];
    
    // init the function arguments in stack
    for (llvm::Argument &arg : funcEntry->args()) {
        llvm::StringRef name = arg.getName();
        [[context currentStack] setObject:&arg forKey:[[RispSymbolExpression alloc] initWithSymbol:[RispSymbol named:[NSString stringWithUTF8String:name.str().c_str()]]]];
    }
    
    // setup meta of work-functions
    RispLLVM::RispLLVMFunctionMeta *functionMeta = [context metaForFunction:funcEntry];
    for (llvm::Function **i = functions.begin(), **e = functions.end(); i != e; i++) {
        llvm::Function *workFunction = *i;
        RispLLVM::RispLLVMFunctionDescriptor descriptor = functionMeta->getDescriptorFromName(workFunction->getName());
        descriptor.setFunction(workFunction);
        functionMeta->setDescriptor(workFunction, descriptor);
    }
    
    RispLLVM::RispLLVMFunctionDescriptor functionDescriptor = functionMeta->getDescriptorFromName(funcEntry->getName());
    functionDescriptor.setFunction(funcEntry, true);
    functionMeta->setDescriptor(funcEntry, functionDescriptor);
    
    llvm::BasicBlock *savePoint = [CGM builder]->GetInsertBlock();
    llvm::IRBuilder<> *builder = [CGM builder];
    builder->SetInsertPoint([CGM CGF].createBasicBlock("entry", funcEntry));
    RispLLVM::CodeGenFunction *CGF = &[CGM CGF];
    
    llvm::Value *vec = [[context currentStack] objectForKey:[[RispSymbolExpression alloc] initWithSymbol:[RispSymbol named:@"vec"]]];
    RispVector *ins = [RispVector empty];
    llvm::Value *argsCount = [CGM emitMessageCall:vec selector:@selector(count) arguments:{} instance:ins];
    
    void (^__emitFuncEntryDispatch)(RispMethodExpression *method, NSUInteger idx) = ^(RispMethodExpression *method, NSUInteger idx) {
        llvm::ConstantInt *methodParamsCount = llvm::ConstantInt::get([CGM longType], [method paramsCount]);
        llvm::Value *check = builder->CreateICmpEQ(argsCount, methodParamsCount);
        __block llvm::Value *retValue = nullptr;
        CGF->EmitBranchBlock(funcEntry, check, ^llvm::BasicBlock *(RispLLVM::CodeGenFunction *CGF, llvm::BasicBlock **blocks) {
            llvm::SmallVector<llvm::Value *, 8>args;
            [__RispLLVMFunctionHelper __argumentsBindingToFunction:vec args:[method requiredParms] function:funcEntry binding:args isVariadic:[method isVariadic] context:context];
            llvm::Function *targetFunc = [__RispLLVMFunctionHelper __functionWithMangling:[RispNameMangling nameMangling] fromName:[[self name] stringValue] arguments:[method requiredParms] context:context];
            retValue = builder->CreateCall(targetFunc, args);
            if (retValue == nil || (retValue->getType() != funcEntryType->getReturnType() && retValue->getType() == [CGM voidType])) {
                retValue = [RispNilExpression emitNSNullWithMeta:context];
            }
            builder->CreateRet(retValue);
            CGF->EmitBranch(blocks[RispLLVM::CodeGenFunction::CGFBranchEndBlockId]);
            return blocks[RispLLVM::CodeGenFunction::CGFBranchTrueBlockId];
        }, ^llvm::BasicBlock *(RispLLVM::CodeGenFunction *CGF, llvm::BasicBlock **blocks) {
            CGF->EmitBranch(blocks[RispLLVM::CodeGenFunction::CGFBranchEndBlockId]);
            return blocks[RispLLVM::CodeGenFunction::CGFBranchFalseBlockId];
        }, ^llvm::BasicBlock *(RispLLVM::CodeGenFunction *CGF, llvm::BasicBlock **blocks) {
            return blocks[RispLLVM::CodeGenFunction::CGFBranchEndBlockId];
        });
    };
    
    NSUInteger idx = 0;
    for (RispMethodExpression *method in [self methods]) {
        __emitFuncEntryDispatch(method, idx++);
    }
    llvm::Value *RispNSExceptionClass = [CGM emitClassNamed:@"NSException" isWeak:NO];
    llvm::Value *exceptionName = [CGM emitObjCStringLiteral:RispIllegalArgumentException];
    llvm::Value *exceptionReason = [CGM emitObjCStringLiteral:@"arguments count is error"];
    [CGM emitMessageCall:RispNSExceptionClass selector:@selector(raise:format:) arguments:{exceptionName, exceptionReason} instance:[NSException class]];
    llvm::Value *retValue = [RispNilExpression emitNSNullWithMeta:context];
    builder->CreateRet(retValue);
    [context popStack];
    builder->SetInsertPoint(savePoint);
    return funcEntry;
}

@end

@implementation RispDefnExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    RispFnExpression *fnExpression = [self value];
    if ([fnExpression name] == nil) {
        [fnExpression setName:[self key]];
    }
    llvm::Function *function = (llvm::Function *)[fnExpression generateCode:context];
    return function;
}

@end

@implementation RispInvokeExpression (IR)

- (void *)_generateFunctionCall:(llvm::Function *)func context:(RispASTContext *)context {
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::SmallVector<llvm::Value *, 8> args;
    for (RispBaseExpression * arg in [self arguments]) {
        llvm::Value *value = (llvm::Value *)[arg generateCode:context];
        args.push_back(value);
    }
    RispLLVM::RispLLVMValueMeta metaOfFunc = [[context currentStack] metaForValue:func];
    llvm::Value *retValue = [CGM builder]->CreateCall(func, args);
    if (metaOfFunc.isValid()) {
        [[context currentStack] setMeta:metaOfFunc forValue:retValue];
    }
    return retValue;
}

- (void *)_generateDispatchCall:(llvm::Function *)func context:(RispASTContext *)context {
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::SmallVector<llvm::Value *, 8> args;
    
    llvm::Value *RispVectorClass = [CGM emitClassNamed:@"RispVector" isWeak:NO];
    for (RispBaseExpression * arg in [self arguments]) {
        llvm::Value *value = (llvm::Value *)[arg generateCode:context];
        args.push_back(value);
    }
    llvm::Value *RispNSArrayClass = [CGM emitClassNamed:@"NSMutableArray" isWeak:NO];
    llvm::ArrayType *arrayType = llvm::ArrayType::get([CGM idType], args.size());
    llvm::Value *cArray = [CGM builder]->CreateAlloca(arrayType);
    for (unsigned idx = 0; idx < args.size(); idx++) {
        llvm::Value *vidx = [CGM builder]->CreateGEP(cArray, {llvm::ConstantInt::get([CGM intType], 0), llvm::ConstantInt::get([CGM intType], idx)});
        llvm::Value *argValue = args[(unsigned)idx];
        [CGM builder]->CreateStore(argValue, vidx);
    }
    llvm::Value *array = [CGM emitMessageCall:RispNSArrayClass selector:@selector(arrayWithObjects:count:) arguments:{cArray, llvm::ConstantInt::get([CGM longType], args.size())} instance:[NSMutableArray class]];
    llvm::Value *vec = [CGM emitMessageCall:RispVectorClass selector:@selector(listWithObjectsFromArray:) arguments:{array} instance:[RispVector class]];
    
    RispLLVM::RispLLVMValueMeta metaOfFunc = [[context currentStack] metaForValue:func];
    llvm::Value *retValue = [CGM builder]->CreateCall(func, vec);
    if (metaOfFunc.isValid()) {
        [[context currentStack] setMeta:metaOfFunc forValue:retValue];
    }
    return retValue;
}

- (void *)_generateCall:(llvm::Function *)func context:(RispASTContext *)context {
    llvm::StringRef name = func->getName();
    BOOL isMangling = [[RispNameMangling nameMangling] isManglingFunction:[NSString stringWithUTF8String:name.str().c_str()] context:context];
    llvm::StringRef realName = name;
    if (isMangling == YES) {
        RispNameManglingFunctionDescriptor *functionDescriptor = [[RispNameMangling nameMangling] demanglingFunctionName:[NSString stringWithUTF8String:name.str().c_str()] context:context];
        realName = [[functionDescriptor functionName] UTF8String];
    }
    llvm::Function *workFunc = [__RispLLVMFunctionHelper __functionWithMangling:[RispNameMangling nameMangling] fromName:[NSString stringWithUTF8String:realName.str().c_str()] arguments:[self arguments] context:context];
    if (workFunc) {
        return [self _generateFunctionCall:workFunc context:context];
    }
    return [self _generateDispatchCall:func context:context];
}

- (void *)generateCode:(RispASTContext *)context {
    __RispLLVMFoundation *CGM __unused = [context CGM];
    RispBaseExpression *expr = [self fexpr];
    if ([expr isKindOfClass:[RispSymbolExpression class]]) {
        // func symbol
        RispSymbolExpression *fnSymbolExpression = (RispSymbolExpression *)expr;
        llvm::Function *func = [__RispLLVMFunctionHelper __functionWithMangling:[RispNameMangling nameMangling] fromName:[fnSymbolExpression stringValue] arguments:[self arguments] context:context];
        if (func != nullptr) {
            return [self _generateFunctionCall:func context:context];
        }
    } else if ([expr isKindOfClass:[RispFnExpression class]]) {
        RispFnExpression *fnExpression = (RispFnExpression *)expr;
        if (![fnExpression name]) {
            [fnExpression setName:[[RispSymbolExpression alloc] initWithSymbol:[RispSymbol named:[NSString stringWithFormat:@"RispAnonymousFunction%ld", [context anonymousFunctionCounter]]]]];
        }
        llvm::Function *func = (llvm::Function *)[fnExpression generateCode:context]; // return dispatch function
        if (func != nullptr) {
            return [self _generateCall:func context:context];
        }
    } else if ([expr isKindOfClass:[RispDotExpression class]]) {
        RispDotExpression *dotExpression = (RispDotExpression *)expr;
        llvm::Value *result = (llvm::Value *)[dotExpression generateCode:context];
        llvm::IRBuilder<> *builder = [CGM builder];
        RispLLVM::RispLLVMValueMeta meta = [[context currentStack] metaForValue:result];
        if (!result) {
            return nil;
        }
        if (meta.isValid() && meta.isFunctionType()) {
            llvm::Function *targetFunc = [__RispLLVMFunctionHelper __functionWithMangling:[RispNameMangling nameMangling] fromName:[NSString stringWithUTF8String:meta.getName().str().c_str()] arguments:[self arguments] context:context];
            if (targetFunc != nullptr) {
                return [self _generateCall:targetFunc context:context];
            } else if ((targetFunc = [CGM module]->getFunction(meta.getName())) != nullptr) {
                return [self _generateCall:targetFunc context:context];
            }
        }
        llvm::Function *func = llvm::dyn_cast<llvm::Function>(result);
        if (func) {
            return [self _generateCall:func context:context];
        } else {
            llvm::SmallVector<llvm::Type *, 8> argumentsTypes;
            NSUInteger count = [[self arguments] count];
            for (NSUInteger idx = 0; idx < count; idx++) {
                argumentsTypes.push_back([CGM idType]);
            }
            llvm::FunctionType *resultFunctionType = llvm::FunctionType::get([CGM idType], argumentsTypes, false);
            llvm::Type *newType = llvm::PointerType::get(resultFunctionType, 0);
            
            llvm::Value *castFunc = [CGM builder]->CreateBitCast(result, newType);
            
            llvm::SmallVector<llvm::Value *, 8> arguments;
            for (RispBaseExpression *expr in [self arguments]) {
                llvm::Value *value = (llvm::Value *)[expr generateCode:context];
                arguments.push_back(builder->CreateBitCast(value, [CGM idType]));
            }
            llvm::CallInst *callInst = builder->CreateCall(castFunc, arguments);
            return callInst;
        }
//        [RispCompilerExceptionLocation exceptionLocationWithExpression:self exception:[NSException exceptionWithName:RispCompilerReturnTypeException reason:@"return type should be an function!" userInfo:@{}]];
    } else if ([expr isKindOfClass:[RispKeywordInvokeExpression class]]) {
        
    } else if ([expr isKindOfClass:[RispInvokeExpression class]]) {
        RispInvokeExpression *invokeExpression = (RispInvokeExpression *)expr;
        llvm::Value *result = (llvm::Value *)[invokeExpression generateCode:context];
        RispLLVM::RispLLVMValueMeta meta = [[context currentStack] metaForValue:result];
        if (!result) {
            return nil;
        }
        if (meta.isValid() && meta.isFunctionType()) {
            llvm::Function *targetFunc = [__RispLLVMFunctionHelper __functionWithMangling:[RispNameMangling nameMangling] fromName:[NSString stringWithUTF8String:meta.getName().str().c_str()] arguments:[self arguments] context:context];
            if (targetFunc != nullptr) {
                return [self _generateCall:targetFunc context:context];
            } else if ((targetFunc = [CGM module]->getFunction(meta.getName())) != nullptr) {
                return [self _generateCall:targetFunc context:context];
            }
        }
        llvm::Function *func = llvm::dyn_cast<llvm::Function>(result);
        if (func) {
            return [self _generateCall:func context:context];
        }
        [RispCompilerExceptionLocation exceptionLocationWithExpression:self exception:[NSException exceptionWithName:RispCompilerReturnTypeException reason:@"return type should be an function!" userInfo:@{}]];
    }
    return nil;
}

@end

@interface RispASTContext () {
    @private
    NSUInteger _anonymousFunctionCounter;
}
@end

@implementation RispASTContext
+ (instancetype)ASTContext {
    static RispASTContext *context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[RispASTContext alloc] initWithName:@"top"];
    });
    return context;
}

+ (NSArray *)expressionFromCurrentLine:(NSString *)sender {
    RispContext *context = [RispContext currentContext];
    RispReader *_reader = [[RispReader alloc] initWithContent:sender fileNamed:@"Risp.Compiler.REPL"];
    id value = nil;
    NSMutableArray *exprs = [[NSMutableArray alloc] init];;
    while (_reader && ![_reader isEnd]) {
        @autoreleasepool {
            @try {
                value = [_reader readEofIsError:YES eofValue:nil isRecursive:YES];
                [[_reader reader] skip];
                if (value == _reader) {
                    continue;
                }
                id expr = [RispCompiler compile:context form:value];
                if (exprs || expr) {
                    [exprs addObject:expr];
                }
//                id v = [expr eval];
//                [values addObject:v ? : [NSNull null]];
//                
//                if ([expr conformsToProtocol:@protocol(RispExpression)]) {
//                    NSLog(@"%@ -\n%@\n-> %@", value, [[[RispAbstractSyntaxTree alloc] initWithExpression:expr] description], v);
//                } else {
//                    NSLog(@"%@ -\n%@\n-> %@", value, [RispAbstractSyntaxTree descriptionAppendIndentation:0 forObject:expr], v);
//                }
            }
            @catch (NSException *exception) {
                NSLog(@"%@ - %@\n%@", value, exception, [exception callStackSymbols]);
            }
        }
    }
    return exprs;
}

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        _CGM = [[__RispLLVMFoundation alloc] initWithModuleName:name];
        _currentStack = [[RispScopeStack alloc] initWithParent:nil];
        
        llvm::FunctionType *mainFuncType = llvm::FunctionType::get([_CGM intType], {[_CGM intType], [_CGM charType]->getPointerTo()->getPointerTo()}, NO);

//        llvm::Function *mainFunc = llvm::Function::Create(mainFuncType, llvm::GlobalValue::ExternalLinkage, "main", [_CGM module]);
//        
//        [__RispLLVMCodeGenFunction setNamesForFunction:mainFunc arugmentNames:{"argc", "argv"}];
//        
//        llvm::BasicBlock* label_entry = llvm::BasicBlock::Create([_CGM module]->getContext(), "entry", mainFunc, 0);
//        [_CGM builder]->SetInsertPoint(label_entry);
        
        llvm::Function *noduleFunc = llvm::Function::Create(mainFuncType, llvm::GlobalValue::ExternalLinkage, [name UTF8String], [_CGM module]);
        
        [__RispLLVMCodeGenFunction setNamesForFunction:noduleFunc arugmentNames:{"argc", "argv"}];
        
        llvm::BasicBlock* label_entry = llvm::BasicBlock::Create([_CGM module]->getContext(), "entry", noduleFunc, 0);
        [_CGM builder]->SetInsertPoint(label_entry);
        
        _autoreleasePoolRoot = [_CGM CGF].EmitObjCAutoreleasePoolPush();
        return self;
    }
    return nil;
}

- (id)CGM {
    return _CGM;
}

- (NSUInteger)anonymousFunctionCounter {
    return _anonymousFunctionCounter++;
}

- (RispScopeStack *)currentStack {
    if (!_currentStack) {
        _currentStack = [[RispScopeStack alloc] init];
    }
    return _currentStack;
}

- (RispScopeStack *)pushStack {
    RispScopeStack *stack = [[RispScopeStack alloc] initWithParent:_currentStack];
    _currentStack = stack;
    return _currentStack;
}

- (void)popStack {
    if ([_currentStack depth] == 0)
        return;
    _currentStack = [_currentStack outer];
}

- (void)emitRispAST:(RispAbstractSyntaxTree *)ast {
    RispBaseExpression* entry = [ast object];
    if (!entry) {
        return;
    }
    if ([entry respondsToSelector:@selector(generateCode:)]) {
        [entry generateCode:self];
    }
}

- (void)doneWithOutputPath:(NSString *)path {
    [_CGM setOutputPath:path];
    std::string name = [_CGM module]->getModuleIdentifier();
    llvm::Function *mainEntry = [_CGM module]->getFunction(name);
    llvm::BasicBlock *back = &mainEntry->getBasicBlockList().back();
    [_CGM builder]->SetInsertPoint(back);
    [_CGM CGF].EmitObjCAutoreleasePoolPop(_autoreleasePoolRoot);
    [_CGM builder]->CreateRet(llvm::ConstantInt::get([_CGM intType], 0));
    NSDictionary *outputs = [_CGM done];
    _asmFilePath = outputs[__RispLLVMFoundationAsmPathKey];
    _objectFilePath = outputs[__RispLLVMFoundationObjectPathKey];
    _llvmirFilePath = outputs[__RispLLVMFoundationLLVMIRPathKey];
    for (RispLLVM::RispLLVMFunctionMeta **i = _globalFunctionMetaSet.begin(), **e = _globalFunctionMetaSet.end(); i != e; i++) {
        RispLLVM::RispLLVMFunctionMeta *meta = *i;
        std::string str;
        (*meta).toString(str);
        printf("%s\n", str.c_str());
        delete meta;
    }
    _globalFunctionMetaSet.erase(_globalFunctionMetaSet.begin(), _globalFunctionMetaSet.end());
    _currentStack = nil;
}

- (RispLLVM::RispLLVMFunctionMeta *)metaForFunction:(llvm::Function *)function {
    llvm::StringRef dispatchFunctionName = function->getName();
    RispNameManglingFunctionDescriptor *descriptor = [[RispNameMangling nameMangling] demanglingFunctionName:[NSString stringWithUTF8String:dispatchFunctionName.str().c_str()] context:self];
    dispatchFunctionName = descriptor ? [[descriptor functionName] UTF8String] : dispatchFunctionName;
    RispLLVM::RispLLVMFunctionMeta *meta = _globalFunctionScope.lookup(dispatchFunctionName);
    if (meta == nullptr) {
        meta = new RispLLVM::RispLLVMFunctionMeta(dispatchFunctionName);
        _globalFunctionMetaSet.push_back(meta);
        _globalFunctionScope[dispatchFunctionName] = meta;
    }
    return meta;
}

@end
