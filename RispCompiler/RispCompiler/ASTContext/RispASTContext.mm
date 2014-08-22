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

@implementation RispNumberExpression (IR)

- (void *)generateCode:(id)context {
    double fvalue = [[self value] doubleValue];
    __RispLLVMFoundation *CGM = [[RispASTContext ASTContext] CGM];
    llvm::Value *RispNSNumberClass = [CGM emitClassNamed:@"NSDecimalNumber" isWeak:NO];
    llvm::Value *arg = llvm::ConstantFP::get([CGM doubleType], fvalue);
    return [CGM emitMessageCall:RispNSNumberClass selector:@selector(numberWithDouble:) arguments:{arg} instance:[NSDecimalNumber class]];
}

@end

@implementation RispStringExpression (IR)

- (void *)generateCode:(id)context {
    NSString *sValue = [self value];
    __RispLLVMFoundation *CGM = [[RispASTContext ASTContext] CGM];
    llvm::Constant *str = [CGM emitObjCStringLiteral:sValue];
    return str;
}

@end

@implementation RispDotExpression (IR)

- (void *)generateCode:(id)context {
    __RispLLVMFoundation *CGM = [[RispASTContext ASTContext] CGM];
    id target = [self target];
    BOOL isClass = [self isClass];
    llvm::Value *llvmTarget = nullptr;
    
//    llvm::Value *ret = [CGM emitMessageCall:llvmTarget selector:[self selector] arguments:<#(llvm::ArrayRef<llvm::Value *>)#> instance:<#(id)#>]
    return nil;
}

@end

@interface RispASTContext () {
    @private
    __RispLLVMFoundation *_CGM;
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
}
@end
