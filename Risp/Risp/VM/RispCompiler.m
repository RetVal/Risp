//
//  RispCompiler.m
//  Risp
//
//  Created by closure on 4/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispCompiler.h>
#import <Risp/RispSymbolExpression.h>
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
//else if ([form isKindOfClass:[NSString class]] ||
//         [form isKindOfClass:[NSNumber class]] ||
//         [form isKindOfClass:[NSRegularExpression class]] ||
//         [form isKindOfClass:[RispVector class]]) {
//    return form;
//}
+ (id)compile:(RispContext *)context form:(id)form {
    
    @autoreleasepool {
        [RispContext setCurrentContext:context];
        if (!form || [form isKindOfClass:[NSNull class]]) {
            return [[[NSNull alloc] init] copyMetaFromObject:form];
        } else if ([form isKindOfClass:[RispSymbol class]]) {
//            return [[context currentScope][form] copyMetaFromObject:form];
            return [RispSymbolExpression parser:form context:context];
        } else if ([form isKindOfClass:[RispKeyword class]]) {
            return [RispKeywordExpression parser:form context:context];
        }
        if ([form isKindOfClass:[RispList class]]) {
            // macroexpand
            form = [RispCompiler macroexpand:form];
            if ([form conformsToProtocol:@protocol(RispSequence)] && [[form first] isEqualTo: [RispSymbol DO]]) {
                return [RispBodyExpression parser:form context:context];
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