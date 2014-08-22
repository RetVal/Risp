//
//  RispDotExpression.m
//  Risp
//
//  Created by closure on 4/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispDotExpression.h"
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"
#include <objc/runtime.h>
#include <objc/message.h>

//(. UIImage imageNamed: "")
@interface NSInvocation (ObjectReturnValue)

- (id)objectReturnValue;

@end

@interface RispDotExpression (NSInvocation)
+ (id)objectiveC:(void *)value methodSignature:(NSMethodSignature *)signature;
@end

@implementation NSInvocation (ObjectReturnValue)

- (id)objectReturnValue {
    void *pointer = nil;
    if ([[self methodSignature] methodReturnLength] == 0) {
        return [NSNull null];
    }
    [self getReturnValue:&pointer];
    __unsafe_unretained id result = (__bridge id)pointer;
    return [RispDotExpression objectiveC:(void *)result methodSignature:[self methodSignature]];
}

@end

@implementation RispDotExpression
+ (id)parser:(id <RispSequence>)form context:(RispContext *)context {
    
    id seq = form;
    id dot __unused = [form first];
    form = [form next];
    id classNameSymbol = [form first];
    RispSymbolExpression *targetSymbolExpression = [RispSymbolExpression parser:classNameSymbol context:context];
    form = [form next];
    id selectorSymbol = [form first];
    RispSelectorExpression *selectorExpression = [RispSelectorExpression parser:selectorSymbol context:context];
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
            if ([form conformsToProtocol:@protocol(RispSequence)]) {
                [form enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [exprsArray addObject:[RispBaseParser analyze:context form:obj]];
                }];
            } else {
                [exprsArray addObject:[RispBaseParser analyze:context form:form]];
            }
        }
        return [[[RispDotExpression alloc] initWithTarget:targetSymbol selector:sel methodSignature:nil expressions:exprsArray ? [RispVector listWithObjectsFromArrayNoCopy:exprsArray] : nil  class:isClass targetSymbolExpression:targetSymbolExpression selectorExpression:selectorExpression] copyMetaFromObject:seq];
    } else {
        targetSymbol = [classNameSymbol eval];
        form = [form eval];
    }
    
    if ([classNameSymbol isKindOfClass:[RispSymbol class]]) {
        targetSymbol = classNameSymbol;
        if (NSClassFromString([targetSymbol stringValue])) {
            isClass = YES;
        }
    } else if ([classNameSymbol conformsToProtocol:@protocol(RispSequence)]) {
        if ([context status] != RispContextEval) {
            [context setStatus:RispContextStatement];
            targetSymbol = [RispBaseParser analyze:context form:classNameSymbol];
        } else {
            targetSymbol = [classNameSymbol eval];
            if ([targetSymbol conformsToProtocol:@protocol(RispExpression)]) {
                targetSymbol = [targetSymbol eval];
            } else if ([targetSymbol isKindOfClass:[RispSymbol class]]) {
                targetSymbol = targetSymbol;
            } else if ([targetSymbol conformsToProtocol:@protocol(RispSequence)]) {
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
            return [[[RispDotExpression alloc] initWithTarget:NSClassFromString(className) selector:sel methodSignature:methodSignature arguments:[RispVector listWithObjectsFromArrayNoCopy:[form array]] class:isClass targetSymbolExpression:targetSymbolExpression selectorExpression:selectorExpression] copyMetaFromObject:seq];
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
        return [[[RispDotExpression alloc] initWithTarget:target selector:sel methodSignature:methodSignature arguments:[RispVector listWithObjectsFromArrayNoCopy:[form array]] class:isClass targetSymbolExpression:targetSymbolExpression selectorExpression:selectorExpression] copyMetaFromObject:seq];
    }
    return nil;
}

- (id)initWithTarget:(id)target selector:(SEL)sel methodSignature:(NSMethodSignature *)methodSignature arguments:(RispVector *)arguments class:(BOOL)class targetSymbolExpression:(RispSymbolExpression *)targetSymbolExpression selectorExpression:(RispSelectorExpression *)selectorExpression {
    if (self = [super init]) {
        _target = target;
        _targetExpression = targetSymbolExpression;
        _selectorExpression = selectorExpression;
        _selector = sel;
        if (arguments) {
            NSMutableArray *args = [[NSMutableArray alloc] init];
            [arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [args addObject:[RispBaseParser analyze:[RispContext currentContext] form:obj]];
            }];
            arguments = [[RispVector alloc] initWithArrayNoCopy:args];
        }
        _evaled = YES;
        _methodSignature = methodSignature;
        _exprs = arguments;
    }
    return self;
}

- (id)initWithTarget:(id)target selector:(SEL)sel methodSignature:(NSMethodSignature *)methodSignature expressions:(id <RispSequence>)exprs class:(BOOL)class targetSymbolExpression:(RispSymbolExpression *)targetSymbolExpression selectorExpression:(RispSelectorExpression *)selectorExpression {
    if (self = [super init]) {
        _target = target;
        _targetExpression = targetSymbolExpression;
        _selectorExpression = selectorExpression;
        _selector = sel;
        _exprs = exprs;
        _Class = class;
        _evaled = NO;
        _methodSignature = methodSignature;
    }
    return self;
}

- (id)evalExpression:(id)target selector:(SEL)selector arguments:(RispVector *)arguments{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:_methodSignature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    for(int i=0; i < [arguments count]; i++) {
        id arg = [[arguments nth:i] eval];
        [invocation setArgument:&arg atIndex: i + 2]; // objc_msgSend(target, selector, ...)
    }
    [invocation invoke]; 
    id value = [invocation objectReturnValue];
    return value;
}

+ (id)objectiveC:(void *)value methodSignature:(NSMethodSignature *)signature {
    NSString *retType = @([signature methodReturnType]);
    if ([retType hasPrefix:@"B"] || [retType hasPrefix:@"b"] ||
        [retType hasPrefix:@"C"] || [retType hasPrefix:@"c"]) {
        return [NSDecimalNumber numberWithBool:(Boolean)value];
    } else if ([retType isEqualToString:@"Q"]) {
        return [NSDecimalNumber numberWithUnsignedLongLong:(unsigned long long)value];
    } else if ([retType isEqualToString:@"L"]) {
        return [NSDecimalNumber numberWithUnsignedLong:(unsigned long)value];
    }
    return (__bridge id)value;
}

- (RispVector *)_setupArguments {
    if (_exprs) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [_exprs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id v = [obj eval];
            [array addObject:v];
        }];
        return [RispVector listWithObjectsFromArrayNoCopy:array];
    }
    return nil;
}

- (id)eval {
    id target = _target;
    SEL selector = _selector;
    RispVector *arguments = nil;
    if (!_evaled) {
        target = [_target eval] ? : [_target description];
        NSString *className = [target respondsToSelector:@selector(stringValue)] ? [target stringValue] : ([target isKindOfClass:[NSString class]] ? target : nil);
        if (className == nil) {
            _Class = NO;
        } else if (NSClassFromString(className)) {
            _Class = YES;
            target = NSClassFromString(className);
        }
        arguments = [self _setupArguments];
        if (_Class) {
            NSMethodSignature *methodSignature = [NSClassFromString(className) methodSignatureForSelector:selector] ? : [NSClassFromString(className) instanceMethodSignatureForSelector:selector];
            if (methodSignature) {
                if ([methodSignature numberOfArguments] - 2 != [arguments count]) {
                    [NSException raise:RispIllegalArgumentException format:@"%@ take %ld arguments, but called with %@", target, [methodSignature numberOfArguments] - 2, arguments];
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
            if ([methodSignature numberOfArguments] - 2 != [arguments count]) {
                [NSException raise:RispIllegalArgumentException format:@"%@ take %ld arguments, but called with %@", target, [methodSignature numberOfArguments] - 2, arguments];
            }
            _methodSignature = methodSignature;
        }
    } else {
        arguments = [self _setupArguments];
    }
    return [self evalExpression:target selector:selector arguments:arguments];
}

+ (RispSymbol *)speicalKey {
    return [RispSymbol named:@"."];
}

- (NSString *)description {
    NSMutableString *argDesc = [[NSMutableString alloc] init];
    [_exprs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [argDesc appendFormat:@"%@ ", [obj description]];
    }];
    NSString *desc = [[NSString alloc] initWithFormat:@"(. %@ %@ %@)", _targetExpression, NSStringFromSelector(_selector), argDesc];
    return desc;
}

- (id)copyWithZone:(NSZone *)zone {
    RispDotExpression *copy = [[RispDotExpression alloc] initWithTarget:_target selector:_selector methodSignature:_methodSignature arguments:nil class:_Class targetSymbolExpression:_targetExpression selectorExpression:_selectorExpression];
    return copy;
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [RispAbstractSyntaxTree descriptionAppendIndentation:indentation desc:desc];
    [desc appendFormat:@"%@ %@\n", [self class], [self rispLocationInfomation]];
    [_targetExpression _descriptionWithIndentation:indentation + 1 desc:desc];
    [_selectorExpression _descriptionWithIndentation:indentation + 1 desc:desc];
    if ([_exprs count]) {
        [RispAbstractSyntaxTree descriptionAppendIndentation:indentation + 1 desc:desc];
        [desc appendString:@"arguments\n"];
    }
    for (NSUInteger idx = 0; idx < [_exprs count]; idx ++) {
        [_exprs[idx] _descriptionWithIndentation:indentation + 2 desc:desc];
    }
}
@end
