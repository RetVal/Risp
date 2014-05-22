//
//  RispCompiler.m
//  Risp
//
//  Created by closure on 4/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispCompiler.h>
#import <Risp/RispSymbol.h>
#import <Risp/RispSymbol+BIF.h>
#import <Risp/RispLexicalScope.h>
#import <Risp/RispList.h>
#import <Risp/RispVector.h>
#import <Risp/RispMap.h>
#import <Risp/RispBaseParser.h>
#import <objc/runtime.h>

#import <Risp/RispMapExpression.h>

@interface RispCompiler()
@property (nonatomic, strong, readonly) RispLexicalScope *localBinding;
@property (nonatomic, strong, readonly) id object;
@end

@implementation RispCompiler
+ (Class)targetIsClass:(id)target {
    if ([target isMemberOfClass:[RispSymbol class]]) {
        return NSClassFromString([target stringValue]);
    } else if ([target isKindOfClass:[NSString class]]) {
        return NSClassFromString(target);
    }
    return nil;
}

/*
static LocalBinding referenceLocal(Symbol sym) {
    if(!LOCAL_ENV.isBound())
        return null;
    LocalBinding b = (LocalBinding) RT.get(LOCAL_ENV.deref(), sym);
    if(b != null)
    {
        ObjMethod method = (ObjMethod) METHOD.deref();
        closeOver(b, method);
    }
    return b;
}

 
static public Var isMacro(Object op) {
    //no local macros for now
    if(op instanceof Symbol && referenceLocal((Symbol) op) != null)
        return null;
    if(op instanceof Symbol || op instanceof Var)
    {
        Var v = (op instanceof Var) ? (Var) op : lookupVar((Symbol) op, false, false);
        if(v != null && v.isMacro())
        {
            if(v.ns != currentNS() && !v.isPublic())
                throw new IllegalStateException("var: " + v + " is not public");
            return v;
        }
    }
    return null;
}
 
public static Object eval(Object form, boolean freshLoader) {
    boolean createdLoader = false;
    if(true)//!LOADER.isBound())
    {
        Var.pushThreadBindings(RT.map(LOADER, RT.makeClassLoader()));
        createdLoader = true;
    }
    try
    {
        Object line = lineDeref();
        Object column = columnDeref();
        if(RT.meta(form) != null && RT.meta(form).containsKey(RT.LINE_KEY))
            line = RT.meta(form).valAt(RT.LINE_KEY);
        if(RT.meta(form) != null && RT.meta(form).containsKey(RT.COLUMN_KEY))
            column = RT.meta(form).valAt(RT.COLUMN_KEY);
        Var.pushThreadBindings(RT.map(LINE, line, COLUMN, column));
        try
        {
            form = macroexpand(form);
            if(form instanceof ISeq && Util.equals(RT.first(form), DO))
            {
                ISeq s = RT.next(form);
                for(; RT.next(s) != null; s = RT.next(s))
                    eval(RT.first(s), false);
                return eval(RT.first(s), false);
            }
            else if((form instanceof IType) ||
                    (form instanceof IPersistentCollection
                     && !(RT.first(form) instanceof Symbol
                          && ((Symbol) RT.first(form)).name.startsWith("def"))))
            {
                ObjExpr fexpr = (ObjExpr) analyze(C.EXPRESSION, RT.list(FN, PersistentVector.EMPTY, form),
                                                  "eval" + RT.nextID());
                IFn fn = (IFn) fexpr.eval();
                return fn.invoke();
            }
            else
            {
                Expr expr = analyze(C.EVAL, form);
                return expr.eval();
            }
        }
        finally
        {
            Var.popThreadBindings();
        }
    }
    
    finally
    {
        if(createdLoader)
            Var.popThreadBindings();
    }
}*/

- (id)initWithObject:(id)object {
    if (self = [super init]) {
        _object = object;
    }
    return self;
}

+ (id)preserveTagWithSequence:(id <RispSequence>)src destination:(id)dst {
    RispSymbol *tag = [RispBaseParser tagOfObject:src];
    if (tag) {
        return [dst withMeta:tag forKey:RispMetaKeyTag];
    }
    return dst;
}

+ (id)macroexpand1:(id)x {
    if ([x conformsToProtocol:@protocol(RispSequence)]) {
        id <RispSequence> form = (id <RispSequence>)x;
        id op = [form first];
        if ([[RispContext defaultContext] isSpecial:op]) {
            return x;
        }
        RispVariable *v = [[RispContext currentContext] isMacro:op];
        if (v) {
            @try {
                //RT.cons(form,RT.cons(LOCAL_ENV.get(),form.next()))
                return [v applyTo:form];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
        } else {
            if ([op isKindOfClass:[RispSymbol class]]) {
                RispSymbol *symbol = op;
                NSString *name = [symbol stringValue];
                
                // (.substring s 2 5) => (. s substring 2 5)
                if ([name characterAtIndex:0] == '.') {
                    if ([form count] < 2) {
                        [NSException raise:RispIllegalArgumentException format:@"Malformed member expression, expecting (.member target ...)"];
                    }
                    if ([name length] == 1) {
                        return x;
                    }
                    RispSymbol *meth = [RispSymbol named:[name substringWithRange:NSMakeRange(1, [name length] - 1)]];
                    id target = [form second];
                    if ([RispCompiler targetIsClass:target] != nil) {
                        target = [[RispList listWithObjects:[RispSymbol IDENTITY], target, nil] withMeta:[RispSymbol named:@"Class"] forKey:RispMetaKeyTag];
                    }
                    return [self preserveTagWithSequence:form destination:[RispList listWithRest:[[form next] next] objects:[RispSymbol DOT], target, meth, nil]];
//                    Symbol meth = Symbol.intern(sname.substring(1));
//                    Object target = RT.second(form);
//                    if(HostExpr.maybeClass(target, false) != null)
//                    {
//                        target = ((IObj)RT.list(IDENTITY, target)).withMeta(RT.map(RT.TAG_KEY,CLASS));
//                    }
//                    return preserveTag(form, RT.listStar(DOT, target, meth, form.next().next()));
                }
            }
        }
    }
    return x;
}

+ (id)macroexpand:(id)form {
    id exf = [self macroexpand1:form];
    if (![exf isEqualTo:form]) {
        return [self macroexpand:exf];
    }
    return form;
}

// eval
                        
+ (id)compile:(RispContext *)context form:(id)form {
    @autoreleasepool {
        [RispContext setCurrentContext:context];
        if (!form || [form isKindOfClass:[NSNull class]]) {
            return [NSNull null];
        } else if ([form isKindOfClass:[NSString class]] ||
                   [form isKindOfClass:[NSNumber class]] ||
                   [form isKindOfClass:[NSRegularExpression class]] ||
                   [form isKindOfClass:[RispVector class]]) {
            return form;
        } else if ([form isKindOfClass:[RispSymbol class]]) {
            return [context currentScope][form];
        } else if ([form isKindOfClass:[RispKeyword class]]) {
            return [RispKeywordExpression parser:form context:context];
        }
        if ([form isKindOfClass:[RispList class]]) {
            // macroexpand
            form = [RispCompiler macroexpand:form];
            if ([form conformsToProtocol:@protocol(RispSequence)] && [[form first] isEqualTo: [RispSymbol DO]]) {
                for (id <RispSequence>seq = [form next]; seq != nil; seq = [seq next]) {
                    [self compile:context form:seq];
                }
            } else {
                return [RispBaseParser analyze:context form:form];
            }
            return form;
        } else if ([form isKindOfClass:[RispMap class]]) {
            return [RispMapExpression parser:form context:context];
        }
    }
    return [RispConstantExpression parser:form context:context];
}


+ (id)eval:(id)rispForm {
    if (!rispForm || [rispForm isKindOfClass:[NSNull class]]) return nil;
    RispContext *context = [RispContext currentContext];
    id expression = nil;
    id v = nil;
    @try {
        expression = [RispCompiler compile:context form:rispForm];
        v = [expression eval];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        
    }
    return v;
}


- (id)isMacro:(id)op {
    if ([op isKindOfClass:[RispSymbol class]] && op) {
        return nil;
    }
    return nil;
}


@end


@interface NSObject (RispCompiler)
- (id)eval;
@end

@implementation NSObject (RispCompiler)
- (id)eval {
    return self;
}
@end