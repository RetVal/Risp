//
//  RispDotExpression.m
//  Risp
//
//  Created by closure on 4/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispDotExpression.h"
#include <objc/runtime.h>
#include <objc/message.h>

//(. UIImage imageNamed: "")
@interface NSInvocation (ObjectReturnValue)

- (id)objectReturnValue;

@end

@implementation NSInvocation (ObjectReturnValue)

- (id)objectReturnValue {
    void *pointer;
    [self getReturnValue:&pointer];
    id result = (__bridge id)pointer;
    return result;
}

@end

@interface RispDotExpression ()
@property (nonatomic, assign, readonly, getter = isClass) BOOL class;
@property (nonatomic, strong, readonly) NSMethodSignature *methodSignature;
@property (nonatomic, assign, readonly) BOOL evaled;
@end
@implementation RispDotExpression
+ (id)parser:(id <RispSequence>)form context:(RispContext *)context {
    
    id dot __unused = [form first];
    form = [form next];
    id classNameSymbol = [form first];
    form = [form next];
    id selectorSymbol = [form first];
    form = [form next];
    SEL sel = NSSelectorFromString([selectorSymbol stringValue]);
    if (sel == nil) {
        [NSException raise:RispIllegalArgumentException format:@"%@ of %@ not found", selectorSymbol, classNameSymbol];
        return nil;
    }
    
    BOOL isClass = NO;
    
    id targetSymbol = nil;
    
    if ([context status] != RispContextEval) {
        [context setStatus:RispContextStatement];
        targetSymbol = [RispBaseParser analyze:context form:classNameSymbol];
        NSMutableArray *exprsArray = nil;
        if (form) {
            exprsArray = [[NSMutableArray alloc] init];
            if ([form conformsToProtocol:NSProtocolFromString(@"RispSequence")]) {
                [form enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [exprsArray addObject:[RispBaseParser analyze:context form:obj]];
                }];
            } else {
                [exprsArray addObject:[RispBaseParser analyze:context form:form]];
            }
        }
        return [[RispDotExpression alloc] initWithTarget:targetSymbol selector:sel methodSignature:nil expressions:exprsArray ? [RispVector listWithObjectsFromArrayNoCopy:exprsArray] : nil  class:isClass];
    } else {
        targetSymbol = [classNameSymbol eval];
        form = [form eval];
    }
    
    if ([classNameSymbol isKindOfClass:[RispSymbol class]]) {
        targetSymbol = classNameSymbol;
        if (NSClassFromString([targetSymbol stringValue])) {
            isClass = YES;
        }
    } else if ([classNameSymbol conformsToProtocol:NSProtocolFromString(@"RispSequence")]) {
        if ([context status] != RispContextEval) {
            [context setStatus:RispContextStatement];
            targetSymbol = [RispBaseParser analyze:context form:classNameSymbol];
        } else {
            targetSymbol = [classNameSymbol eval];
            if ([targetSymbol conformsToProtocol:NSProtocolFromString(@"RispBaseExpression")]) {
                targetSymbol = [targetSymbol eval];
            } else if ([targetSymbol isKindOfClass:[RispSymbol class]]) {
                targetSymbol = targetSymbol;
            } else if ([targetSymbol conformsToProtocol:NSProtocolFromString(@"RispSequence")]) {
                targetSymbol = [[RispBaseParser analyze:context form:targetSymbol] eval];
            }
            if (NSClassFromString([targetSymbol respondsToSelector:@selector(stringValue)] ? [targetSymbol stringValue] : ([targetSymbol isKindOfClass:[NSString class]] ? targetSymbol : @""))) {
                isClass = YES;
            }
        }
    }
    

    NSString *className = [targetSymbol respondsToSelector:@selector(stringValue)] ? [targetSymbol stringValue] : ([targetSymbol isKindOfClass:[NSString class]] ? targetSymbol : nil);
    if (className == nil)
        isClass = NO;
    if (isClass) {
        NSMethodSignature *methodSignature = [NSClassFromString(className) methodSignatureForSelector:sel] ? : [NSClassFromString(className) instanceMethodSignatureForSelector:sel];
        if (methodSignature) {
            if ([methodSignature numberOfArguments] - 2 != [form count]) {
                [NSException raise:RispIllegalArgumentException format:@"%@ take %ld arguments, but called with %@", classNameSymbol, [methodSignature numberOfArguments] - 2, form];
            }
            return [[RispDotExpression alloc] initWithTarget:NSClassFromString(className) selector:sel methodSignature:methodSignature arguments:[RispVector listWithObjectsFromArrayNoCopy:[form array]] class:isClass];
        }
        [NSException raise:RispIllegalArgumentException format:@"%@ of %@ is not found", selectorSymbol, className];
    } else {
        id target = ([context currentScope][targetSymbol]) ? : [targetSymbol eval];
        NSMethodSignature *methodSignature = [[target class] instanceMethodSignatureForSelector:sel] ? : [target methodSignatureForSelector:sel];
        if (!methodSignature) {
            [NSException raise:RispIllegalArgumentException format:@"%@ is not found", selectorSymbol];
        }
        if ([methodSignature numberOfArguments] - 2 != [form count]) {
            [NSException raise:RispIllegalArgumentException format:@"%@ take %ld arguments, but called with %@", targetSymbol, [methodSignature numberOfArguments] - 2, form];
        }
        return [[RispDotExpression alloc] initWithTarget:target selector:sel methodSignature:methodSignature arguments:[RispVector listWithObjectsFromArrayNoCopy:[form array]] class:isClass];
    }
    return nil;
}

- (id)initWithTarget:(id)target selector:(SEL)sel methodSignature:(NSMethodSignature *)methodSignature arguments:(RispVector *)arguments class:(BOOL)class {
    if (self = [super init]) {
        _target = target;
        _selector = sel;
        if (arguments) {
            NSMutableArray *args = [[NSMutableArray alloc] init];
            [arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [args addObject:[RispBaseParser analyze:[RispContext currentContext] form:obj]];
            }];
            _arguments = [[RispVector alloc] initWithArrayNoCopy:args];
        }
        _evaled = YES;
        _methodSignature = methodSignature;
    }
    return self;
}

- (id)initWithTarget:(id)target selector:(SEL)sel methodSignature:(NSMethodSignature *)methodSignature expressions:(id <RispSequence>)exprs class:(BOOL)class {
    if (self = [super init]) {
        _target = target;
        _selector = sel;
        _exprs = exprs;
        _class = class;
        _evaled = NO;
        _methodSignature = methodSignature;
    }
    return self;
}

- (id)evalExpression:(id)target selector:(SEL)selector {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:_methodSignature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    for(int i=0; i < [_arguments count]; i++) {
        id arg = [[_arguments nth:i] eval];
        [invocation setArgument:&arg atIndex: i + 2]; // objc_msgSend(target, selector, ...)
    }
    
    [invocation invoke]; 
    id value = [invocation objectReturnValue];
    _arguments = nil;
    return [self objectiveC:value methodSignature:_methodSignature];
}

- (id)objectiveC:(id)value methodSignature:(NSMethodSignature *)signature {
    NSString *retType = @([signature methodReturnType]);
    if ([retType hasPrefix:@"B"] || [retType hasPrefix:@"b"] ||
        [retType hasPrefix:@"C"] || [retType hasPrefix:@"c"]) {
        return [NSNumber numberWithBool:(Boolean)value];
    }
    return value;
}

- (void)_initArguments {
    if (!_arguments && _exprs) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [_exprs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id v = [obj eval];
            [array addObject:v];
        }];
        _arguments = [RispVector listWithObjectsFromArrayNoCopy:array];
    }
}

- (id)eval {
    id target = _target;
    SEL selector = _selector;
    if (!_evaled) {
        target = [_target eval] ? : [_target description];
        NSString *className = [target respondsToSelector:@selector(stringValue)] ? [target stringValue] : ([target isKindOfClass:[NSString class]] ? target : nil);
        if (className == nil) {
            _class = NO;
        } else if (NSClassFromString(className)) {
            _class = YES;
            target = NSClassFromString(className);
        }
        [self _initArguments];
        if (_class) {
            NSMethodSignature *methodSignature = [NSClassFromString(className) methodSignatureForSelector:selector] ? : [NSClassFromString(className) instanceMethodSignatureForSelector:selector];
            if (methodSignature) {
                if ([methodSignature numberOfArguments] - 2 != [_arguments count]) {
                    [NSException raise:RispIllegalArgumentException format:@"%@ take %ld arguments, but called with %@", target, [methodSignature numberOfArguments] - 2, _arguments];
                }
                _methodSignature = methodSignature;
            } else {
                [NSException raise:RispIllegalArgumentException format:@"%@ of %@ is not found", NSStringFromSelector(selector), className];
            }
        } else {
            target = ([[RispContext currentContext] currentScope][target]) ? : [target eval];
            NSMethodSignature *methodSignature = [[target class] instanceMethodSignatureForSelector:selector] ? : [target methodSignatureForSelector:selector];
            if (!methodSignature) {
                [NSException raise:RispIllegalArgumentException format:@"%@ is not found", NSStringFromSelector(selector)];
            }
            if ([methodSignature numberOfArguments] - 2 != [_arguments count]) {
                [NSException raise:RispIllegalArgumentException format:@"%@ take %ld arguments, but called with %@", target, [methodSignature numberOfArguments] - 2, _arguments];
            }
            _methodSignature = methodSignature;
        }
    }
    return [self evalExpression:target selector:selector];
}

+ (RispSymbol *)speicalKey {
    return [RispSymbol named:@"."];
}

- (NSString *)description {
    NSMutableString *argDesc = [[NSMutableString alloc] init];
    [_exprs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [argDesc appendFormat:@"%@ ", [obj description]];
    }];
    NSString *desc = [[NSString alloc] initWithFormat:@"(. %@ %@ %@)", _target, NSStringFromSelector(_selector), argDesc];
    return desc;
}
@end
