//
//  __RispLLVMFoundation.m
//  Risp
//
//  Created by closure on 6/10/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "__RispLLVMFoundation.h"

#include "llvm/Transforms/Scalar.h"
#include "llvm/IR/DataLayout.h"

#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Support/FormattedStream.h"

#include "llvm/IR/Verifier.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/JIT.h"
#include "llvm/Pass.h"
#include "llvm/PassManager.h"
#include "llvm/PassRegistry.h"
#include "llvm/InitializePasses.h"

#import "__RispLLVMObjcType.h"
#include "CodeGenFunction.h"
#include "RispLLVMSelector.h"
#include "llvm/ADT/Hashing.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/Support/ConvertUTF.h"

#include "llvm/ADT/SmallString.h"

NSString * __RispLLVMFoundationObjectPathKey = @"ObjectPath";
NSString * __RispLLVMFoundationAsmPathKey = @"AsmPath";
NSString * __RispLLVMFoundationLLVMIRPathKey = @"LLVM-IR-Path";

namespace RispLLVM {
    class Selector;
    class IdentifierInfo;
    static bool containsNonAsciiOrNull(llvm::StringRef str) {
        for (unsigned i = 0, e = str.size(); i != e; ++i)
            if (!isascii(str[i]) || !str[i])
                return true;
        return false;
    }
}

enum ImageInfoFlags {
    eImageInfo_FixAndContinue      = (1 << 0), // This flag is no longer set by clang.
    eImageInfo_GarbageCollected    = (1 << 1),
    eImageInfo_GCOnly              = (1 << 2),
    eImageInfo_OptimizedByDyld     = (1 << 3), // This flag is set by the dyld shared cache.
    
    // A flag indicating that the module has no instances of a @synthesize of a
    // superclass variable. <rdar://problem/6803242>
    eImageInfo_CorrectedSynthesize = (1 << 4), // This flag is no longer set by clang.
    eImageInfo_ImageIsSimulated    = (1 << 5)
};

/// Define DenseMapInfo so that Selectors can be used as keys in DenseMap and
/// DenseSets.
template <>
struct llvm::DenseMapInfo<RispLLVM::Selector> {
    static inline RispLLVM::Selector getEmptyKey() {
        return RispLLVM::Selector::getEmptyMarker();
    }
    static inline RispLLVM::Selector getTombstoneKey() {
        return RispLLVM::Selector::getTombstoneMarker();
    }
    
    static unsigned getHashValue(RispLLVM::Selector S) {
        return (unsigned)[[[NSString alloc] initWithUTF8String:S.getAsString().c_str()] hash];
    }
    
    static bool isEqual(RispLLVM::Selector LHS, RispLLVM::Selector RHS) {
        return LHS == RHS;
    }
};

template <>
struct llvm::DenseMapInfo<RispLLVM::IdentifierInfo> {
    static inline RispLLVM::IdentifierInfo getEmptyKey() {
        return *RispLLVM::IdentifierInfo::getEmptyMarker();
    }
    static inline RispLLVM::IdentifierInfo getTombstoneKey() {
        return *RispLLVM::IdentifierInfo::getTombstoneMarker();
    }
    
    static unsigned getHashValue(RispLLVM::IdentifierInfo S) {
        return static_cast<size_t>(llvm::hash_value(S.getName()));
    }
    
    static bool isEqual(RispLLVM::IdentifierInfo LHS, RispLLVM::IdentifierInfo RHS) {
        return LHS == RHS;
    }
};

namespace LangAS {
    
    /// \brief Defines the set of possible language-specific address spaces.
    ///
    /// This uses a high starting offset so as not to conflict with any address
    /// space used by a target.
    enum ID {
        Offset = 0xFFFF00,
        
        opencl_global = Offset,
        opencl_local,
        opencl_constant,
        
        cuda_device,
        cuda_constant,
        cuda_shared,
        
        Last,
        Count = Last-Offset
    };
    
    /// The type of a lookup table which maps from language-specific address spaces
    /// to target-specific ones.
    typedef unsigned Map[Count];
    
}


//static llvm::IRBuilder<> _builder(llvm::getGlobalContext());
using namespace llvm;

typedef llvm::ArrayRef<llvm::Type*> TypeArray;

@interface __RispLLVMFoundation () {
    llvm::LLVMContext *_context;
    llvm::Module *_theModule;
    llvm::DataLayout *_dataLayout;
    
    RispLLVM::CodeGenFunction *_CGF;
    
    __RispLLVMTargetCodeGenInfo *_targetCodeGenInfo;
    
    std::map <std::string, llvm::Value *>_nameValues;
    llvm::IRBuilder<> *_builder;
    llvm::ExecutionEngine *_executeEngine;
    
    __RispLLVMObjcType *_objcType;
    
    llvm::SmallPtrSet<llvm::GlobalValue*, 10> WeakRefReferences;
    llvm::StringMap<Constant *>NSConstantStringMap;
    
    llvm::StringMap<llvm::GlobalVariable *>Constant1ByteStringMap;
    
    llvm::SetVector<RispLLVM::IdentifierInfo> LazySymbols;
    
    llvm::DenseMap<RispLLVM::Selector, llvm::GlobalVariable*> SelectorReferences;
    llvm::DenseMap<RispLLVM::IdentifierInfo, llvm::GlobalVariable*> ClassReferences;
    llvm::DenseMap<RispLLVM::IdentifierInfo, llvm::GlobalVariable*> SuperClassReferences;
    llvm::DenseMap<RispLLVM::IdentifierInfo, llvm::GlobalVariable*> MetaClassReferences;
    llvm::DenseMap<RispLLVM::Selector, llvm::GlobalVariable*> MethodVarNames;
    
    llvm::StructType * _NSConstantStringClassTy;
    llvm::Value *_CFConstantStringClassReference;
    
    const LangAS::Map *_addrSpaceMap;
    
    std::vector<llvm::WeakVH> LLVMUsed;
    std::vector<llvm::WeakVH> LLVMCompilerUsed;
    RispLLVM::LanguageOptions _languageOptions;
    BOOL _ObjCABI;
}
@end

@implementation __RispLLVMFoundation
- (llvm::Module *)module {
    return _theModule;
}

- (IRBuilder<> *)builder {
    return _builder;
}

- (llvm::LLVMContext *)llvmContext {
    return _context;
}

- (StringMap<llvm::Constant *>&)stringMap {
    return NSConstantStringMap;
}

- (RispLLVM::CodeGenFunction &)CGF {
    return *_CGF;
}

- (llvm::StructType *)NSConstantStringClassTy {
    if (!_NSConstantStringClassTy) {
        llvm::Type *fieldTypes[4];
        fieldTypes[0] = llvm::PointerType::getUnqual([_objcType intType]);
        fieldTypes[1] = llvm::IntegerType::getInt32Ty(*_context);
        fieldTypes[2] = [_objcType selectorType];
        fieldTypes[3] = [_objcType longType];
        _NSConstantStringClassTy = llvm::StructType::create(*_context, fieldTypes, "struct.NSConstantString");
    }
    return _NSConstantStringClassTy;
}

- (llvm::CallingConv::ID)runtimeCC {
    return [_targetCodeGenInfo runtimeCC];
}

- (__RispLLVMTargetCodeGenInfo *)targetCodeGenInfo {
    return _targetCodeGenInfo;
}

- (llvm::Value *)CFConstantStringClassReference {
    if (!_CFConstantStringClassReference) {
        llvm::Type *ty = [_objcType intType];
        ty = llvm::ArrayType::get(ty, 0);
        llvm::Constant *gv = [self getOrCreateLLVMGlobal:"__CFConstantStringClassReference" type:llvm::PointerType::getUnqual(ty) unnamedAddress:YES];
        llvm::Constant *zero = llvm::Constant::getNullValue([_objcType intType]);
        llvm::Constant *zeros[] = { zero, zero };
        _CFConstantStringClassReference = llvm::ConstantExpr::getGetElementPtr(gv, zeros);
    }
    return _CFConstantStringClassReference;
}

- (id)initWithModuleName:(NSString *)name {
    if (self = [super init]) {
        _context = &getGlobalContext();
        _ObjCABI = 2;
        _theModule = new Module([name UTF8String], *(_context));
        _builder = new IRBuilder<>(*_context);
        _dataLayout = new llvm::DataLayout([self module]);
        _objcType = [__RispLLVMObjcType helper];
        _targetCodeGenInfo = [[__RispLLVMTargetCodeGenInfo alloc] init];
        _CGF = new RispLLVM::CodeGenFunction(self);
        _moduleName = name;
    }
    return self;
}

- (unsigned)targetAddressSpace:(unsigned)AS {
    if (AS < LangAS::Offset || AS >= LangAS::Offset + LangAS::Count)
        return AS;
    else
        return (*_addrSpaceMap)[AS - LangAS::Offset];
}

- (unsigned)globalVarAddressSpace:(unsigned)addressSpace {
    return [self targetAddressSpace:addressSpace];
}

- (llvm::Constant*)getOrCreateLLVMFunction:(StringRef)mangledName type:(llvm::Type *)ty forVTable:(BOOL)forVTable dontDefer:(BOOL)dontDefer attribute:(llvm::AttributeSet)extraAttrs {
    // Lookup the entry, lazily creating it if necessary.
    llvm::GlobalValue *entry = [self globalValue:mangledName];
    if (entry) {
        if (WeakRefReferences.erase(entry)) {
//            const FunctionDecl *FD = cast_or_null<FunctionDecl>(D);
//            if (FD && !FD->hasAttr<WeakAttr>())
//                Entry->setLinkage(llvm::Function::ExternalLinkage);
        }
        
        if (entry->getType()->getElementType() == ty)
            return entry;
        
        // Make sure the result is of the correct type.
        return llvm::ConstantExpr::getBitCast(entry, ty->getPointerTo());
    }
    
    // This function doesn't have a complete type (for example, the return
    // type is an incomplete struct). Use a fake type instead, and make
    // sure not to try to set attributes.
    bool isIncompleteFunction = false;
    
    llvm::FunctionType *functionType;
    if (llvm::isa<llvm::FunctionType>(ty)) {
        functionType = llvm::cast<llvm::FunctionType>(ty);
    } else {
        functionType = llvm::FunctionType::get([_objcType voidType], false);
        isIncompleteFunction = true;
    }
    
    llvm::Function *function = llvm::Function::Create(functionType, llvm::Function::ExternalLinkage, mangledName, [self module]);
    assert(function->getName() == mangledName && "name was uniqued!");
//    if (D)
//        SetFunctionAttributes(GD, F, IsIncompleteFunction);
    if (extraAttrs.hasAttributes(llvm::AttributeSet::FunctionIndex)) {
        llvm::AttrBuilder builder(extraAttrs, llvm::AttributeSet::FunctionIndex);
        function->addAttributes(llvm::AttributeSet::FunctionIndex,
                                llvm::AttributeSet::get(*_context,
                                                        llvm::AttributeSet::FunctionIndex,
                                                        builder));
    }
    
    //    if (!DontDefer) {
    //        // All MSVC dtors other than the base dtor are linkonce_odr and delegate to
    //        // each other bottoming out with the base dtor.  Therefore we emit non-base
    //        // dtors on usage, even if there is no dtor definition in the TU.
    //        if (D && isa<CXXDestructorDecl>(D) &&
    //            getCXXABI().useThunkForDtorVariant(cast<CXXDestructorDecl>(D),
    //                                               GD.getDtorType()))
    //            addDeferredDeclToEmit(F, GD);
    //
    //        // This is the first use or definition of a mangled name.  If there is a
    //        // deferred decl with this name, remember that we need to emit it at the end
    //        // of the file.
    //        llvm::StringMap<GlobalDecl>::iterator DDI = DeferredDecls.find(MangledName);
    //        if (DDI != DeferredDecls.end()) {
    //            // Move the potentially referenced deferred decl to the
    //            // DeferredDeclsToEmit list, and remove it from DeferredDecls (since we
    //            // don't need it anymore).
    //            addDeferredDeclToEmit(F, DDI->second);
    //            DeferredDecls.erase(DDI);
    //
    //            // Otherwise, if this is a sized deallocation function, emit a weak
    //            // definition
    //            // for it at the end of the translation unit.
    //        } else if (D && cast<FunctionDecl>(D)
    //                   ->getCorrespondingUnsizedGlobalDeallocationFunction()) {
    //            addDeferredDeclToEmit(F, GD);
    //
    //            // Otherwise, there are cases we have to worry about where we're
    //            // using a declaration for which we must emit a definition but where
    //            // we might not find a top-level definition:
    //            //   - member functions defined inline in their classes
    //            //   - friend functions defined inline in some class
    //            //   - special member functions with implicit definitions
    //            // If we ever change our AST traversal to walk into class methods,
    //            // this will be unnecessary.
    //            //
    //            // We also don't emit a definition for a function if it's going to be an
    //            // entry
    //            // in a vtable, unless it's already marked as used.
    //        } else if (getLangOpts().CPlusPlus && D) {
    //            // Look for a declaration that's lexically in a record.
    //            const FunctionDecl *FD = cast<FunctionDecl>(D);
    //            FD = FD->getMostRecentDecl();
    //            do {
    //                if (isa<CXXRecordDecl>(FD->getLexicalDeclContext())) {
    //                    if (FD->isImplicit() && !ForVTable) {
    //                        assert(FD->isUsed() &&
    //                               "Sema didn't mark implicit function as used!");
    //                        addDeferredDeclToEmit(F, GD.getWithDecl(FD));
    //                        break;
    //                    } else if (FD->doesThisDeclarationHaveABody()) {
    //                        addDeferredDeclToEmit(F, GD.getWithDecl(FD));
    //                        break;
    //                    }
    //                }
    //                FD = FD->getPreviousDecl();
    //            } while (FD);
    //        }
    //    }
    
//    getTargetCodeGenInfo().emitTargetMD(D, F, *this);
    
    // Make sure the result is of the requested type.
    if (!isIncompleteFunction) {
        assert(function->getType()->getElementType() == ty);
        return function;
    }
    
    llvm::Type *pty = llvm::PointerType::getUnqual(ty);
    llvm::Constant *c = llvm::ConstantExpr::getBitCast(function, pty);
    llvm::GlobalValue* gv = llvm::cast<llvm::GlobalValue>(c);
    gv->setLinkage(llvm::Function::ExternalWeakLinkage);
    WeakRefReferences.insert(gv);
    return c;
}

//+ (void)_optimizeFunction:(Function *)f
//{
//    static FunctionPassManager *fpm;
//    if(!fpm)
//    {
//        fpm = new FunctionPassManager(ArrayMapProxyLLVMModule);
//        
//        fpm->add(new DataLayoutPass(*ArrayMapProxyLLVMEngine->getDataLayout()));
//        fpm->add(createPromoteMemoryToRegisterPass());
//        fpm->add(createInstructionCombiningPass());
//        fpm->add(createReassociatePass());
//        fpm->add(createGVNPass());
//        fpm->add(createCFGSimplificationPass());
//    }
//    fpm->run(*f);
//}

- (void)dealloc {
    [self doneWithOptions:RispASTContextDoneWithShowNothing];
    if (_builder) {
        delete _builder;
        _builder = nil;
    }
    
    if (_theModule) {
        delete _theModule;
        _theModule = nil;
    }
    
    if (_CGF) {
        delete [] _CGF;
    }
}

- (RispLLVM::LanguageOptions &)languageOptions {
    return _languageOptions;
}

@end

@implementation __RispLLVMFoundation (CPP)

@end

@implementation __RispLLVMFoundation (TypeHelper)
- (llvm::IntegerType *)intType {
    return [_objcType intType];
}

- (llvm::IntegerType *)charType {
    return [_objcType charType];
}

- (llvm::PointerType *)intptrType {
    return [_objcType intptrType];
}

- (llvm::IntegerType *)int64Type {
    return [_objcType int64Type];
}

- (llvm::IntegerType *)longType {
    return [_objcType longType];
}

- (llvm::PointerType *)idType {
    return [_objcType idType];
}

- (llvm::PointerType *)selectorType {
    return [_objcType selectorType];
}

- (llvm::Type *)voidType {
    return [_objcType voidType];
}

- (llvm::Type *)floatType {
    return [_objcType llvmTypeFromObjectiveCType:@encode(float)];
}

- (llvm::Type *)doubleType {
    return [_objcType llvmTypeFromObjectiveCType:@encode(double)];
}

- (llvm::Type *)ptrDiffType {
    return [_targetCodeGenInfo pointerDiffType];
}

- (llvm::Type *)classType {
    return [_objcType classnfABITy];
}

- (llvm::PointerType *)classPtrTYpe {
    return llvm::dyn_cast<llvm::PointerType>([_objcType classnfABIPtrTy]);
}

- (llvm::Type *)llvmTypeFromObjectiveCType:(const char *)type {
    return [_objcType llvmTypeFromObjectiveCType:type];
}
@end

@implementation __RispLLVMFoundation (Value)
- (Value *)valueForPointer:(void *)ptr builder:(IRBuilder<> &)builder type:(Type *)type name:(const char *)name {
    Value *intv = ConstantInt::get([_objcType int64Type], (int64_t)ptr, 0);
    return builder.CreateIntToPtr(intv, type, name);
}

- (Value *)valueForSelector:(SEL)aSEL builder:(IRBuilder<> &)builder {
    return [self valueForPointer:aSEL builder:builder type:[_objcType selectorType] name:sel_getName(aSEL)];
}

- (Value *)valueForClass:(Class)aClass builder:(IRBuilder<> &)builder {
    return [self valueForPointer:(__bridge void *)aClass builder:builder type:[_objcType idType] name:class_getName(aClass)];
}

- (llvm::Constant *)emitNullConstant:(llvm::Type *)t {
    if (t->isArrayTy()) {
        llvm::ArrayType *arrayType = cast<llvm::ArrayType>(t);
        llvm::Type *elementType = arrayType->getElementType();
        llvm::Constant *element = [self emitNullConstant:elementType];
        if (element->isNullValue()) {
            return llvm::ConstantAggregateZero::get(arrayType);
        }
        unsigned numberElements = (unsigned)arrayType->getNumElements();
        llvm::SmallVector<llvm::Constant *, 8> array(numberElements, element);
        return llvm::ConstantArray::get(arrayType, array);
    } else if (t->isPointerTy()) {
        return llvm::ConstantPointerNull::get(llvm::cast<llvm::PointerType>(t));
    }
    return llvm::Constant::getNullValue(t);
}
@end


@implementation __RispLLVMFoundation (Function)

- (llvm::Function *)msgSend {
    static Function *f;
    if(!f)
    {
        SmallVector<Type *, 16> vec;
        vec.append(1, [_objcType idType]);
        vec.append(1, [_objcType selectorType]);
        ArrayRef<Type *> msgSendArgTypes = makeArrayRef(vec);
        FunctionType *msgSendType = FunctionType::get([_objcType idType], msgSendArgTypes, true);
        f = Function::Create(msgSendType,
                             Function::ExternalLinkage,
                             "objc_msgSend",
                             _theModule);
    }
    return f;
}

- (llvm::Constant *)createRuntimeFunciton:(llvm::FunctionType *)functionTy name:(StringRef)name extraAttributes:(llvm::AttributeSet)extraAttrs {
    llvm::Constant *c = [self getOrCreateLLVMFunction:name type:functionTy forVTable:false dontDefer:false attribute:extraAttrs];
    if (llvm::Function *f = dyn_cast<llvm::Function>(c)) {
        if (f->empty()) {
            f->setCallingConv([self runtimeCC]);
        }
    }
    return c;
}
@end

@implementation __RispLLVMFoundation (Memory)

- (llvm::Value *)malloc:(NSUInteger)size {
    BasicBlock* BB = _builder->GetInsertBlock();
    ConstantInt *val_mem = ConstantInt::get(*_context, APInt(32, size));
    Type* IntPtrTy = [self intType];
    Type* Int8Ty = [self charType];
    Constant* allocsize = ConstantExpr::getSizeOf(Int8Ty);
    allocsize = ConstantExpr::getTruncOrBitCast(allocsize, IntPtrTy);
    return CallInst::CreateMalloc(BB, IntPtrTy, Int8Ty, allocsize, val_mem, NULL, "arr");
}

- (llvm::Value *)malloc:(NSUInteger)size inBlock:(llvm::BasicBlock *)bb {
    return llvm::CallInst::CreateMalloc(bb, nil, nil, nil);
}

@end

@implementation __RispLLVMFoundation (Call)
- (llvm::Value *)msgSendToTarget:(id)target selector:(SEL)cmd arguments:(NSArray *)arguments {
    if (!target) {
        return nil;
    }
    __block std::vector<llvm::Value *> args;
    [arguments enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
        args.push_back((llvm::Value *)[obj pointerValue]);
    }];
    return [self _msgSendToTarget:target selector:cmd arguments:args];
}

- (llvm::Value *)_msgSendToTarget:(id)target selector:(SEL)cmd arguments:(std::vector<llvm::Value *>)arguments {
    return [self msgSend:[self valueForPointer:(__bridge void *)target builder:*_builder type:[_objcType idType] name:"self"] selector:cmd arguments:arguments];
}

- (llvm::Value *)msgSend:(llvm::Value *)target selector:(SEL)cmd arguments:(std::vector<llvm::Value *>)arguments {
    llvm::Function *f = [self msgSend];
    llvm::Function::arg_iterator args = f->arg_begin();
    llvm::Value *selfarg = args++;
    selfarg->setName("self");
    llvm::Value *_cmdarg = args++;
    _cmdarg->setName("_cmd");
    std::vector<llvm::Value *>callArgs;
    callArgs.push_back(target);
    callArgs.push_back([self valueForSelector:cmd builder:*_builder]);
    for (std::vector<llvm::Value *>::iterator it = arguments.begin(); it != arguments.end(); it++) {
        callArgs.push_back(*it);
    }
    return _builder->CreateCall(f, makeArrayRef(callArgs), "msgSend");
}

- (llvm::Value *)emitMessageCall:(llvm::Value *)target selector:(SEL)selector arguments:(llvm::ArrayRef<llvm::Value *>)_args instance:(id)ins {
    llvm::Value *sel = [self emitSelector:RispLLVM::Selector(selector) isValue:NO];
    if (!sel) return nil;
    llvm::Constant *msgSend = [_objcType messageSendFn:self];
    llvm::SmallVector<llvm::Value *, 5> args;
    args.push_back(_builder->CreateBitCast(target, [_objcType idType]));
    args.push_back(sel);
    if (_args.size()) {
        args.append(_args.begin(), _args.end());
    }
    msgSend = [__RispLLVMCodeGenFunction castFunctionType:msgSend arguments:args selector:selector instance:ins];
    llvm::CallInst *call = _builder->CreateCall(msgSend, args);
    return call;
}

@end

@implementation __RispLLVMFoundation (Literal)

- (llvm::GlobalValue *)globalValue:(llvm::StringRef)name {
    return (*[self module]).getNamedValue(name);
}

- (llvm::Value *)emitNSDecimalNumberLiteral:(double)value {
    llvm::Value *RispNSNumberClass = [self emitClassNamed:@"NSDecimalNumber" isWeak:NO];
    llvm::Value *arg = llvm::ConstantFP::get([self doubleType], value);
    llvm::Value *ret = [self emitMessageCall:RispNSNumberClass selector:@selector(numberWithDouble:) arguments:{arg} instance:[NSDecimalNumber class]];
    return ret;
}

- (llvm::Value *)emitNSNull {
    llvm::Value *RispNSNullClass = [self emitClassNamed:@"NSNull" isWeak:NO];
    llvm::Value *ret = [self emitMessageCall:RispNSNullClass selector:@selector(null) arguments:{} instance:[NSNull class]];
    return ret;
}

- (llvm::GlobalVariable *)generateStringLiteral:(StringRef)string isConstant:(BOOL)constant globalName:(const char *)globalName alignment:(unsigned)alignment {
    llvm::Constant *c = llvm::ConstantDataArray::getString(*[self llvmContext], string, NO);
    unsigned addrSpace = 0;
    llvm::GlobalVariable *gv = new llvm::GlobalVariable(*[self module], c->getType(), constant, llvm::GlobalVariable::PrivateLinkage, c, globalName, 0, llvm::GlobalVariable::NotThreadLocal, addrSpace);
    gv->setAlignment(alignment);
    gv->setUnnamedAddr(true);
    return gv;
}

- (llvm::Constant *)getAddrOfConstantString:(StringRef)str globalName:(const char *)globalName alignment:(unsigned)alignment {
    if (!globalName) globalName = ".str";
    if (alignment == 0)
        alignment = 1;
    llvm::StringMapEntry<llvm::GlobalVariable *>&entry = Constant1ByteStringMap.GetOrCreateValue(str);
    
    llvm::GlobalVariable * gv = entry.getValue();
    if (gv) {
        if (alignment > gv->getAlignment()) {
            gv->setAlignment(alignment);
        }
        return gv;
    }
    gv = [self generateStringLiteral:str isConstant:YES globalName:globalName alignment:alignment];
    return gv;
}

- (llvm::Constant *)getOrCreateLLVMGlobal:(llvm::StringRef)name type:(llvm::PointerType *)ty unnamedAddress:(BOOL)unnamedAddress {
    llvm::GlobalValue *entry = [self globalValue:name];
    if (entry) {
        if (unnamedAddress) {
            entry->setUnnamedAddr(true);
        }
        if (entry->getType() == ty) {
            return entry;
        }
        
        if (entry->getType()->getAddressSpace() != ty->getAddressSpace()) {
            return llvm::ConstantExpr::getAddrSpaceCast(entry, ty);
        }
        return llvm::ConstantExpr::getBitCast(entry, ty);
    }
    unsigned addrSpace = [self globalVarAddressSpace:ty->getAddressSpace()];
    llvm::GlobalVariable *gv = new llvm::GlobalVariable(*[self module], ty->getElementType(), false, llvm::GlobalValue::ExternalLinkage, 0, name, 0, llvm::GlobalVariable::NotThreadLocal, addrSpace);
    if (addrSpace != ty->getAddressSpace()) {
        return llvm::ConstantExpr::getAddrSpaceCast(gv, ty);
    }
    return gv;
}

- (llvm::Constant *)emitConstantCStringLiteral:(const std::string &)string globalName:(const char *)globalName alignment:(unsigned)alignment {
    llvm::StringRef  strWithNull(string.c_str(), string.size() + 1);
    return [self getAddrOfConstantString:strWithNull globalName:globalName alignment:alignment];
}

- (llvm::StringMapEntry<Constant *> &)constantStringEntry:(llvm::StringMap<Constant *>&)map literal:(const std::string *)literal length:(size_t &)stringLength isUTF16:(bool &)isUTF16 {
    llvm::StringRef string = llvm::StringRef(*literal);
    stringLength = string.size();
    unsigned NumBytes = string.size();
    
    // Check for simple case.
    if (!RispLLVM::containsNonAsciiOrNull(string)) {
        stringLength = NumBytes;
        return map.GetOrCreateValue(string);
    }
    
    // Otherwise, convert the UTF8 literals into a string of shorts.
    isUTF16 = true;
    
    SmallVector<UTF16, 128> ToBuf(NumBytes + 1); // +1 for ending nulls.
    const UTF8 *FromPtr = (const UTF8 *)string.data();
    UTF16 *ToPtr = &ToBuf[0];
    
    (void)ConvertUTF8toUTF16(&FromPtr, FromPtr + NumBytes,
                             &ToPtr, ToPtr + NumBytes,
                             strictConversion);
    
    // ConvertUTF8toUTF16 returns the length in ToPtr.
    stringLength = ToPtr - &ToBuf[0];
    
    // Add an explicit null.
    *ToPtr = 0;
    return map.GetOrCreateValue(StringRef(reinterpret_cast<const char *>(ToBuf.data()),
                                          (stringLength + 1) * 2));
}

- (llvm::Constant *)emitObjCStringLiteral:(NSString *)string {
    size_t length = 0;
    
    uint8_t *ptr = (uint8_t *)[string UTF8String];
    std::string str = std::string((char *)ptr);
    
    bool isUTF16 = false;
    
    llvm::StringMapEntry<llvm::Constant *> &entry = [self constantStringEntry:NSConstantStringMap literal:&str length:length isUTF16:isUTF16];
    if (llvm::Constant *c = entry.getValue()) {
        return c;
    }
    llvm::Type *ty = [_objcType intType];
    llvm::Constant *zero = llvm::Constant::getNullValue([_objcType intType]);
    llvm::Constant *zeros[] = { zero, zero };
    
    llvm::StructType *sty = cast<llvm::StructType>([self NSConstantStringClassTy]);
    llvm::Constant *fields[4];
    fields[0] = cast<llvm::ConstantExpr>([self CFConstantStringClassReference]);
    fields[1] = isUTF16 ? llvm::ConstantInt::get(ty, 0x07D0) : llvm::ConstantInt::get(ty, 0x07C8);
    llvm::Constant *c = 0;
    
    if (isUTF16) {
        llvm::ArrayRef<uint16_t> arr = llvm::makeArrayRef<uint16_t>(reinterpret_cast<uint16_t *>(const_cast<char *>(entry.getKey().data())), entry.getKey().size() / 2);
        c = llvm::ConstantDataArray::get(*_context, arr);
    } else {
        c = llvm::ConstantDataArray::getString(*_context, entry.getKey());
    }
    
    llvm::GlobalVariable *gv = new llvm::GlobalVariable(*[self module], c->getType(), true, llvm::GlobalValue::PrivateLinkage, c, ".str");
    gv->setUnnamedAddr(true);
    if (isUTF16) {
        gv->setAlignment(2);
        gv->setSection("__TEXT,__ustring");
    } else {
        gv->setAlignment(1);
        gv->setSection("__TEXT,__cstring,cstring_literals");
    }
    fields[2] = llvm::ConstantExpr::getGetElementPtr(gv, zeros);
    if (isUTF16) {
        fields[2] = llvm::ConstantExpr::getBitCast(fields[2], [_objcType int8PtrType]);
    }
    ty = [_objcType longType];
    fields[3] = llvm::ConstantInt::get(ty, length);
    c = llvm::ConstantStruct::get(sty, fields);
    gv = new llvm::GlobalVariable(*[self module], c->getType(), true, llvm::GlobalVariable::PrivateLinkage, c, "_unnamed_cfstring_");
    gv->setSection("__DATA,__cfstring");
    entry.setValue(gv);
    return gv;
}


@end

@implementation __RispLLVMFoundation (Selector)

- (llvm::GlobalVariable *)createMetadataVar:(Twine)name init:(llvm::Constant *)init section:(const char *)section alignment:(unsigned)align addToUse:(BOOL)addToUsed {
    llvm::Type *ty = init->getType();
    llvm::GlobalVariable *gv = new llvm::GlobalVariable(*[self module], ty, false, llvm::GlobalValue::InternalLinkage, init, name);
//    assertPrivateName(GV);
    if (section)
        gv->setSection(section);
    if (align)
        gv->setAlignment(align);
    if (addToUsed)
        [self addCompilerUsedGlobal:gv];
    return gv;
}

- (llvm::Constant *)methodVarName:(RispLLVM::Selector)selector {
    llvm::GlobalVariable *&entry = MethodVarNames[selector];
    if (!entry) {
        entry = [self createMetadataVar:"\01L_OBJC_METH_VAR_NAME_" init:llvm::ConstantDataArray::getString(*_context, selector.getAsString()) section:((_ObjCABI == 2) ? "__TEXT,__objc_methname,cstring_literals" : "__TEXT,__cstring,cstring_literals") alignment:1 addToUse:YES];
    }
    return [__RispLLVMFoundation constantGEP:*_context constant:entry idx0:0 idx1:0];
}

- (llvm::Value *)emitSelector:(RispLLVM::Selector)selector isValue:(BOOL)lval {
    llvm::GlobalVariable *&entry = SelectorReferences[selector];
    if (!entry) {
        llvm::Constant *casted = llvm::ConstantExpr::getBitCast([self methodVarName:selector],
                                                                [_objcType selectorType]);
        
//        entry = [self createMetadataVar:"\01L_OBJC_SELECTOR_REFERENCES_" init:casted
//                                section:"__OBJC,__message_refs,literal_pointers,no_dead_strip" alignment:4 addToUse:YES];
        entry = new llvm::GlobalVariable(*[self module], [_objcType selectorType], false,
                                         llvm::GlobalValue::InternalLinkage,
                                         casted, "\01L_OBJC_SELECTOR_REFERENCES_");
        entry->setExternallyInitialized(true);
        entry->setSection("__DATA, __objc_selrefs, literal_pointers, no_dead_strip");
        [self addCompilerUsedGlobal:entry];
    }
    if (lval) {
        return entry;
    }
    llvm::LoadInst *li = [self builder]->CreateLoad(entry);
    li->setMetadata((*[self module]).getMDKindID("invariant.load"),
                    llvm::MDNode::get(*_context, llvm::ArrayRef<llvm::Value *>()));
    return li;
}

@end

@implementation __RispLLVMFoundation (Class)

- (std::string)objcClassSymbolPrefix {
    return "OBJC_CLASS_$_";
}

- (std::string)metaClassSymbolPrefix {
    return "OBJC_METACLASS_$_";
}

- (llvm::GlobalVariable *)classGlobalWithName:(const std::string&)name isWeak:(BOOL)weak {
    llvm::GlobalValue::LinkageTypes L = weak ? llvm::GlobalValue::ExternalWeakLinkage : llvm::GlobalValue::ExternalLinkage;
    llvm::GlobalVariable *gv = [self module]->getGlobalVariable(name);
    if (!gv) {
        gv = new llvm::GlobalVariable(*[self module], [[__RispLLVMObjcType helper] classnfABITy],
                                      false, L, 0, name);
    }
    assert(gv->getLinkage() == L);
    return gv;
}

- (llvm::Value *)emitClassRefFromId:(RispLLVM::IdentifierInfo *)II isWeak:(BOOL)weak {
    // II should be singleton and heap-able
    LazySymbols.insert(*II);
    llvm::GlobalVariable *&entry = ClassReferences[*II];
    if (!entry) {
        std::string className([self objcClassSymbolPrefix] + II->getName().str());
        llvm::GlobalVariable *classGV = [self classGlobalWithName:className isWeak:weak];
        entry = new llvm::GlobalVariable(*[self module], [[__RispLLVMObjcType helper] classnfABIPtrTy],
                                         false, llvm::GlobalValue::InternalLinkage,
                                         classGV,
                                         "\01L_OBJC_CLASSLIST_REFERENCES_$_");
        entry->setAlignment(_dataLayout->getABITypeAlignment([_objcType classnfABIPtrTy]));
        entry->setSection("__DATA, __objc_classrefs, regular, no_dead_strip");
        ClassReferences[*II] = entry;
        [self addCompilerUsedGlobal:entry];
    }
    return [self builder]->CreateLoad(entry);
}

- (llvm::Value *)emitAutoreleasePoolClassRef {
    return [self emitClassNamed:@"NSAutoreleasePool" isWeak:NO];
}

- (llvm::Value *)emitClassNamed:(NSString *)name isWeak:(BOOL)weak {
    RispLLVM::IdentifierInfo II = RispLLVM::IdentifierInfo([name UTF8String]);
    llvm::Value *ret = [self emitClassRefFromId:&II isWeak:weak];
    return ret;
}

- (llvm::Value *)emitSuperClassRef:(RispLLVM::IdentifierInfo *)II isWeak:(BOOL)weak {
    llvm::GlobalVariable *&entry = SuperClassReferences[*II];
    if (!entry) {
        std::string className([self objcClassSymbolPrefix] + II->getName().str());
        llvm::GlobalVariable *classGV = [self classGlobalWithName:className isWeak:weak];
        entry = new llvm::GlobalVariable(*[self module], [_objcType classnfABIPtrTy],
                                         false, llvm::GlobalValue::PrivateLinkage,
                                         classGV,
                                         "\01L_OBJC_CLASSLIST_SUP_REFS_$_");
        entry->setAlignment(_dataLayout->getABITypeAlignment([_objcType classnfABIPtrTy]));
        entry->setSection("__DATA, __objc_superrefs, regular, no_dead_strip");
        SuperClassReferences[*II] = entry;
        [self addCompilerUsedGlobal:entry];
    }
    return [self builder]->CreateLoad(entry);
}

- (llvm::Value *)emitMetaClassRef:(RispLLVM::IdentifierInfo *)II isWeak:(BOOL)weak {
    llvm::GlobalVariable *&entry = MetaClassReferences[*II];
    if (!entry) {
        std::string metaClassName([self metaClassSymbolPrefix] + II->getName().str());
        llvm::GlobalVariable *metaClassGV = [self classGlobalWithName:metaClassName isWeak:weak];
        entry = new llvm::GlobalVariable(*[self module], [_objcType classnfABIPtrTy],
                                         false, llvm::GlobalValue::PrivateLinkage,
                                         metaClassGV,
                                         "\01L_OBJC_CLASSLIST_SUP_REFS_$_");
        entry->setAlignment(_dataLayout->getABITypeAlignment([_objcType classnfABIPtrTy]));
        entry->setSection("__DATA, __objc_superrefs, regular, no_dead_strip");
        MetaClassReferences[*II] = entry;
        [self addCompilerUsedGlobal:entry];
    }
    return [self builder]->CreateLoad(entry);
}

- (llvm::Value *)classFromIdentifierInfo:(RispLLVM::IdentifierInfo *)II isWeak:(BOOL)weak {
    if (weak) {
        std::string className([self objcClassSymbolPrefix] + II->getName().str());
        llvm::GlobalVariable *classGV = [self classGlobalWithName:className isWeak:true];
        (void)classGV;
        assert(classGV->getLinkage() == llvm::GlobalVariable::ExternalWeakLinkage);
    }
    return [self emitClassRefFromId:II isWeak:weak];
}

- (llvm::Value *)emitClass {
    return nil;
}

@end

@implementation __RispLLVMFoundation (Used)

- (void)addUsedGlobal:(llvm::GlobalValue *)gv {
    assert(!gv->isDeclaration() &&
           "Only globals with definition can force usage.");
    LLVMUsed.push_back(gv);
}

- (void)addCompilerUsedGlobal:(llvm::GlobalValue *)gv {
    assert(!gv->isDeclaration() &&
           "Only globals with definition can force usage.");
    LLVMCompilerUsed.push_back(gv);
}

- (void)emitUsedName:(llvm::StringRef)name list:(std::vector<llvm::WeakVH> &)list {
    if (list.empty()) {
        return;
    }
    llvm::SmallVector<llvm::Constant*, 8> usedArray;
    usedArray.resize((unsigned int)list.size());
    for (unsigned idx = 0, e = (unsigned)list.size(); idx != e; idx++) {
        usedArray[idx] = llvm::ConstantExpr::getBitCast(cast<llvm::Constant>(&*list[idx]), [_objcType int8PtrType]);
    }
    
    if (usedArray.empty()) {
        return;
    }
    
    llvm::ArrayType *aty = llvm::ArrayType::get([_objcType int8PtrType], usedArray.size());
    llvm::GlobalVariable *gv = new llvm::GlobalVariable(*[self module], aty, false, llvm::GlobalValue::AppendingLinkage, llvm::ConstantArray::get(aty, usedArray), name);
    gv->setSection("llvm.metadata");
}

- (void)emitLLVMUsed {
    [self emitUsedName:"llvm.used" list:LLVMUsed];
    [self emitUsedName:"llvm.compiler.used" list:LLVMCompilerUsed];
}

- (void)emitImageInfo {
    unsigned version = 0; // Version is unused?
    const char *Section = (_ObjCABI == 1) ?
    "__OBJC, __image_info,regular" :
    "__DATA, __objc_imageinfo, regular, no_dead_strip";
    
    // Generate module-level named metadata to convey this information to the
    // linker and code-gen.
    llvm::Module &mod = *[self module];
    
    // Add the ObjC ABI version to the module flags.
    mod.addModuleFlag(llvm::Module::Error, "Objective-C Version", _ObjCABI);
    mod.addModuleFlag(llvm::Module::Error, "Objective-C Image Info Version",
                      version);
    mod.addModuleFlag(llvm::Module::Error, "Objective-C Image Info Section",
                      llvm::MDString::get(*_context, Section));
    
    mod.addModuleFlag(llvm::Module::Override,
                      "Objective-C Garbage Collection", (uint32_t)0);
    
    // Indicate whether we're compiling this to run on a simulator.
//    const llvm::Triple &Triple = CGM.getTarget().getTriple();
    const llvm::Triple &triple = *[_targetCodeGenInfo targetTriple];
    if (triple.isiOS() &&
        (triple.getArch() == llvm::Triple::x86 ||
         triple.getArch() == llvm::Triple::x86_64))
        mod.addModuleFlag(llvm::Module::Error, "Objective-C Is Simulated", eImageInfo_ImageIsSimulated);
}

- (void)emitVersionIdentMetadata {
    llvm::NamedMDNode *IdentMetadata = [self module]->getOrInsertNamedMetadata("llvm.ident");
    std::string Version = "RispLLVM Version 0.1";
    llvm::LLVMContext &Ctx = *_context;
    
    llvm::Value *IdentNode[] = {
        llvm::MDString::get(Ctx, Version)
    };
    IdentMetadata->addOperand(llvm::MDNode::get(Ctx, IdentNode));
}

- (void)emitLazySymbols {
    if (!LazySymbols.empty()) {
        llvm::SmallString<256> Asm;
        llvm::Module *Module = _theModule;
        Asm += Module->getModuleInlineAsm();
        if (!Asm.empty() && Asm.back() != '\n')
            Asm += '\n';
        
        llvm::raw_svector_ostream OS(Asm);
        //        for (llvm::SetVector<RispLLVM::IdentifierInfo*>::iterator I = DefinedSymbols.begin(),
        //             e = DefinedSymbols.end(); I != e; ++I)
        //            OS << "\t.objc_class_name_" << (*I)->getName() << "=0\n"
        //            << "\t.globl .objc_class_name_" << (*I)->getName() << "\n";
        for (llvm::SetVector<RispLLVM::IdentifierInfo>::iterator I = LazySymbols.begin(),
             e = LazySymbols.end(); I != e; ++I) {
            OS << "\t.lazy_reference .objc_class_name_" << (I)->getName() << "\n";
//            delete *I;
        }
        
        
        
        //        for (size_t i = 0, e = DefinedCategoryNames.size(); i < e; ++i) {
        //            OS << "\t.objc_category_name_" << DefinedCategoryNames[i] << "=0\n"
        //            << "\t.globl .objc_category_name_" << DefinedCategoryNames[i] << "\n";
        //        }
        
        Module->setModuleInlineAsm(OS.str());
    }
}

- (NSDictionary *)doneWithOptions:(RispASTContextDoneOptions)options {
    [self emitLLVMUsed];
    [self emitImageInfo];
    [self emitVersionIdentMetadata];
    [self emitLazySymbols];
    
    BOOL isDirectory = NO;
    if (_outputPath == nil || ([[NSFileManager defaultManager] fileExistsAtPath:[_outputPath stringByStandardizingPath] isDirectory:&isDirectory] && isDirectory == NO)) {
        _outputPath = [[NSFileManager defaultManager] currentDirectoryPath];
    } else {
        _outputPath = [_outputPath stringByStandardizingPath];
    }
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    if (options & (RispASTContextDoneWithShowIRCode | RispASTContextDoneWithOutputIRCode)) {
        NSString *IRCode = [__RispLLVMIRCodeGen IRCodeFromModule:[self module]];
        if (options & RispASTContextDoneWithShowIRCode) {
            printf("RispLLVM ->\n%s\n", [IRCode UTF8String]);
        }
        if (options & RispASTContextDoneWithOutputIRCode) {
            NSString *llvmIRPath = [NSString stringWithFormat:@"%@/%@.ll", _outputPath, _moduleName];
            [IRCode writeToFile:llvmIRPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            result[__RispLLVMFoundationLLVMIRPathKey] = llvmIRPath;
        }
    }
    
    if (options & (RispASTContextDoneWithShowASMCode | RispASTContextDoneWithOutputASMCode)) {
        std::string output;
        [__RispLLVMTargetMachineCodeGen compileASMModule:[self module] context:*[self llvmContext] output:output];
        if (options & RispASTContextDoneWithShowASMCode) {
            printf("RispLLVM -\n%s\n", output.c_str());
        }
        if (options & RispASTContextDoneWithOutputASMCode) {
            NSString *asmPath = [NSString stringWithFormat:@"%@/%@.S", _outputPath, _moduleName];
            [[[NSString alloc] initWithUTF8String:output.c_str()] writeToFile:asmPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            result[__RispLLVMFoundationAsmPathKey] = asmPath;
        }
    }
    
    if (options & RispASTContextDoneWithOutputObjectFile) {
        NSString *objectPath = [NSString stringWithFormat:@"%@/%@.o", _outputPath, _moduleName];
        [__RispLLVMTargetMachineCodeGen compileObjectModule:[self module] context:*[self llvmContext] outputPath:objectPath];
        result[__RispLLVMFoundationObjectPathKey] = objectPath;
    }
    
    return result;
}

@end

@implementation __RispLLVMFoundation (Helper)

+ (llvm::Constant *)constantGEP:(llvm::LLVMContext &)VMContext constant:(llvm::Constant *)c idx0:(unsigned)idx0 idx1:(unsigned)idx1 {
    llvm::Value *idxs[] = {
        llvm::ConstantInt::get(llvm::Type::getInt32Ty(VMContext), idx0),
        llvm::ConstantInt::get(llvm::Type::getInt32Ty(VMContext), idx1)
    };
    return llvm::ConstantExpr::getGetElementPtr(c, idxs);
}

- (llvm::Value *)createVariable:(llvm::Type *)type named:(llvm::StringRef)name {
    llvm::AllocaInst *alloc = _builder->CreateAlloca(type);
    alloc->setName(name);
    alloc->setAlignment(_dataLayout->getABITypeAlignment(type));
    return alloc;
}

- (llvm::Value *)setValue:(llvm::Value *)value forVariable:(llvm::Value *)variable {
    llvm::Type *valueType = value->getType();
    llvm::Type *variableType = variable->getType()->getPointerElementType();
    if (valueType != variableType) {
        value = [__RispLLVMTypeConverter conversionValue:value toType:variableType CGM:self];
    }
    return _builder->CreateStore(value, variable);
}

- (llvm::Value *)setValue:(llvm::Value *)value forVariable:(llvm::Value *)variable isVolatile:(BOOL)isVolatile {
    return _builder->CreateStore(value, variable, isVolatile);
}

- (llvm::Value *)valueForVariable:(llvm::Value *)variable {
    return _builder->CreateLoad(variable);
}

@end

@implementation __RispLLVMFoundation (Math)

- (llvm::Value *)mul:(llvm::Value *)lhs rhs:(llvm::Value *)rhs {
    return _builder->CreateMul(lhs, rhs);
}

- (llvm::Value *)mul:(llvm::ArrayRef<llvm::Value *>)values {
    if (values.size() == 0) return nil;
    else if (values.size() == 1) return values[0];
    llvm::Value *r = _builder->CreateMul(values[0], values[1]);
    for (size_t i = 2; i < values.size(); ++i) {
        llvm::Value *v = values[i];
        r = _builder->CreateMul(r, v);
    }
    return r;
}

@end

@implementation __RispLLVMFoundation (Load)

+ (void)load {
    LLVMInitializeNativeTarget();
//    llvm::LLVMContext &Context = llvm::getGlobalContext();
//    llvm::Type *int1Ty = llvm::Type::getInt1Ty(Context);
//    llvm::Type *int8Ty = llvm::Type ::getInt8Ty(Context);
//    llvm::Type *int32Ty = llvm::Type::getInt32Ty(Context);
//    llvm::FunctionType *fty = llvm::FunctionType::get(int8Ty->getPointerTo(), {int32Ty}, NO);
//    fty->getPointerTo()->dump();
//    printf("\n");
//    llvm::Type::getFloatTy(Context)->dump();
//    printf("\n");
//    __RispLLVMFoundation *CGM = [[__RispLLVMFoundation alloc] initWithModuleName:@""];
//    llvm::Function *func = llvm::dyn_cast<llvm::Function>([[__RispLLVMObjcType helper] messageSendFixupFn:CGM]);
//    if (func) {
//        [[__RispLLVMObjcType helper] categoryTy]->dump();
//        printf("\n");
//        llvm::ArrayType::get([[__RispLLVMObjcType helper] categoryTy], 5)->dump();
//        printf("\n");
//    }
    return;
}

@end

@implementation __RispLLVMFoundation (Layout)
#import "CGBlockInfo.h"

- (llvm::Constant *)buildRCBlockLayout:(const RispLLVM::CGBlockInfo &)blockInfo {
    assert(self.languageOptions.getGC() == RispLLVM::LanguageOptions::NonGC);
    
//    RunSkipBlockVars.clear();
    bool hasUnion = false;
    unsigned WordSizeInBits = [[self targetCodeGenInfo] pointerWidth:0];
    unsigned ByteSizeInBits = [[self targetCodeGenInfo] charWidth];
    unsigned WordSizeInBytes = WordSizeInBits/ByteSizeInBits;
    
//    const BlockDecl *blockDecl = blockInfo.getBlockDecl();
    
    // Calculate the basic layout of the block structure.
    const llvm::StructLayout *layout = _dataLayout->getStructLayout(blockInfo.StructureType);
    
    // Ignore the optional 'this' capture: C++ objects are not assumed
    // to be GC'ed.
//    if (blockInfo.BlockHeaderForcedGapSize != RispLLVM::CharUnits::Zero())
//        UpdateRunSkipBlockVars(false, RispLLVM::Qualifiers::OCL_None,
//                               blockInfo.BlockHeaderForcedGapOffset,
//                               blockInfo.BlockHeaderForcedGapSize);
//    // Walk the captured variables.
//    for (const auto &CI : blockDecl->captures()) {
//        const VarDecl *variable = CI.getVariable();
//        QualType type = variable->getType();
//        
//        const CGBlockInfo::Capture &capture = blockInfo.getCapture(variable);
//        
//        // Ignore constant captures.
//        if (capture.isConstant()) continue;
//        
//        CharUnits fieldOffset =
//        CharUnits::fromQuantity(layout->getElementOffset(capture.getIndex()));
//        
//        assert(!type->isArrayType() && "array variable should not be caught");
//        if (!CI.isByRef())
//            if (const RecordType *record = type->getAs<RecordType>()) {
//                BuildRCBlockVarRecordLayout(record, fieldOffset, hasUnion);
//                continue;
//            }
//        CharUnits fieldSize;
//        if (CI.isByRef())
//            fieldSize = CharUnits::fromQuantity(WordSizeInBytes);
//        else
//            fieldSize = CGM.getContext().getTypeSizeInChars(type);
//        UpdateRunSkipBlockVars(CI.isByRef(), getBlockCaptureLifetime(type, false),
//                               fieldOffset, fieldSize);
//    }
    return nullptr;
//    return getBitmapBlockLayout(false);
}

@end