//
//  RispASTContext.m
//  RispCompiler
//
//  Created by closure on 8/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispASTContext.h"
#import "../RispLLVM/__RispLLVMFoundation.h"
#import "../RispLLVM/__RispLLVMFoundation+Context.h"

#import <Risp/Risp.h>
#import <RispCompiler/RispScopeStack.h>
#import <RispCompiler/RispSymbolExpression+Meta.h>

@interface RispASTContext () {
@private
    __RispLLVMFoundation *_CGM;
    RispScopeStack *_currentStack;
}
- (RispScopeStack *)currentStack;
- (RispScopeStack *)pushStack;
- (void)popStack;
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
    llvm::Value *ret = [CGM emitMessageCall:RispRispSequenceClass selector:@selector(listWithObjects:) arguments:args instance:[RispList class]];
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
    [[self reverse] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        args.push_back((llvm::Value *)[obj generateCode:context]);
    }];
    args.push_back(llvm::ConstantPointerNull::get([CGM idType]));
    llvm::Value *ret = [CGM emitMessageCall:RispRispVectorClass selector:@selector(listWithObjects:) arguments:args instance:[RispList class]];
    [[context currentStack] setMeta:RispLLVM::RispLLVMValueMeta("RispVector") forValue:ret];
    return ret;
    return nil;
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
    llvm::Value *RispNSNumberClass = [CGM emitClassNamed:@"NSDecimalNumber" isWeak:NO];
    llvm::Value *arg = llvm::ConstantFP::get([CGM doubleType], fvalue);
    llvm::Value *ret = [CGM emitMessageCall:RispNSNumberClass selector:@selector(numberWithDouble:) arguments:{arg} instance:[NSDecimalNumber class]];
    [[context currentStack] setMeta:std::move(RispLLVM::RispLLVMValueMeta("NSDecimalNumber")) forValue:ret];
    return ret;
}

@end

@implementation RispFalseExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    double fvalue = [[self value] doubleValue];
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::Value *RispNSNumberClass = [CGM emitClassNamed:@"NSDecimalNumber" isWeak:NO];
    llvm::Value *arg = llvm::ConstantFP::get([CGM doubleType], fvalue);
    llvm::Value *ret = [CGM emitMessageCall:RispNSNumberClass selector:@selector(numberWithDouble:) arguments:{arg} instance:[NSDecimalNumber class]];
    [[context currentStack] setMeta:std::move(RispLLVM::RispLLVMValueMeta("NSDecimalNumber")) forValue:ret];
    return ret;
}

@end

@implementation RispNumberExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    double fvalue = [[self value] doubleValue];
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::Value *RispNSNumberClass = [CGM emitClassNamed:@"NSDecimalNumber" isWeak:NO];
    llvm::Value *arg = llvm::ConstantFP::get([CGM doubleType], fvalue);
    llvm::Value *ret = [CGM emitMessageCall:RispNSNumberClass selector:@selector(numberWithDouble:) arguments:{arg} instance:[NSDecimalNumber class]];
    [[context currentStack] setMeta:std::move(RispLLVM::RispLLVMValueMeta("NSDecimalNumber")) forValue:ret];
    return ret;
}

@end

@implementation RispNilExpression (IR)

- (void *)generateCode:(RispASTContext *)context {
    __RispLLVMFoundation *CGM = [context CGM];
    llvm::Value *RispNSNullClass = [CGM emitClassNamed:@"NSNull" isWeak:NO];
    llvm::Value *ret = [CGM emitMessageCall:RispNSNullClass selector:@selector(null) arguments:{} instance:[NSNull class]];
    [[context currentStack] setMeta:std::move(RispLLVM::RispLLVMValueMeta("NSNull")) forValue:ret];
    return ret;
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
            [NSException raise:RispRuntimeException format:@"symbol -> %@ is nil", [self stringValue]];
        }
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
        ins = NSClassFromString(@(metaOfTarget.getClassName().str().c_str()));
    } else if (metaOfTarget.isInstanceType()) {
        ins = [[NSClassFromString(@(metaOfTarget.getClassName().str().c_str())) alloc] init];
    }
    
    llvm::SmallVector<llvm::Value *, 8> args;
    for (RispBaseExpression *expr in [self exprs]) {
        args.push_back((llvm::Value *)[expr generateCode:context]);
    }
    llvm::Value *ret = [CGM emitMessageCall:llvmTarget selector:selector arguments:args instance:ins];
    RispLLVM::Selector sel (selector, ins);
    RispLLVM::RispLLVMValueMeta meta = RispLLVM::RispLLVMValueMeta(metaOfTarget.getClassName());
    if (sel.returnTypeIsClass()) {
        meta.setIsClass(true);
    } else if (sel.returnTypeIsInstance()) {
        meta.setIsInstance(true);
    } else if (sel.returnTypeIsSelector()) {
        meta.setIsSelector(true);
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

@implementation RispASTContext
+ (instancetype)ASTContext {
    static RispASTContext *context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[RispASTContext alloc] init];
    });
    return context;
}

+ (NSArray *)expressionFromCurrentLine:(NSString *)sender {
    RispContext *context = [RispContext currentContext];
    RispReader *_reader = [[RispReader alloc] initWithContent:sender fileNamed:@"Risp.Compiler.REPL"];
    id value = nil;
//    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSMutableArray *exprs = [[NSMutableArray alloc] init];;
    while (![_reader isEnd]) {
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

- (instancetype)init {
    if (self = [super init]) {
        _CGM = [[__RispLLVMFoundation alloc] init];
        _currentStack = [[RispScopeStack alloc] initWithParent:nil];
        
//        llvm::FunctionType *testFuncType = llvm::FunctionType::get([_CGM voidType], {}, NO);
//        llvm::Function *testFunc = llvm::Function::Create(testFuncType, llvm::GlobalValue::ExternalLinkage, "+", [_CGM module]);
//        [_CGM builder]->SetInsertPoint([_CGM CGF].createBasicBlock("entry", testFunc, 0));
//        [_CGM builder]->CreateRetVoid();
//        [_CGM CGF].createReturn(nil, testFunc);
        
        llvm::FunctionType *mainFuncType = llvm::FunctionType::get([_CGM intType], {[_CGM intType], [_CGM charType]->getPointerTo()->getPointerTo()}, NO);

        llvm::Function *mainFunc = llvm::Function::Create(mainFuncType, llvm::GlobalValue::ExternalLinkage, "main", [_CGM module]);
        
        [__RispLLVMCodeGenFunction setNamesForFunction:mainFunc arugmentNames:{"argc", "argv"}];
        
        llvm::BasicBlock* label_entry = llvm::BasicBlock::Create([_CGM module]->getContext(), "entry", mainFunc, 0);
        [_CGM builder]->SetInsertPoint(label_entry);
        return self;
    }
    return nil;
}

- (id)CGM {
    return _CGM;
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

- (void)done {
    llvm::Function *mainEntry = [_CGM module]->getFunction("main");
    llvm::BasicBlock *back = &mainEntry->getBasicBlockList().back();
    [_CGM builder]->SetInsertPoint(back);
    [_CGM builder]->CreateRet(llvm::ConstantInt::get([_CGM intType], 0));
    [_CGM done];
    _currentStack = nil;
}
@end
