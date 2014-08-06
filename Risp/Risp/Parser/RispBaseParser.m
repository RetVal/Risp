//
//  RispBaseParser.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispBaseParser.h>
#import <Risp/RispContext.h>
#import <Risp/RispSequence.h>
#import <Risp/RispList.h>
#import <Risp/RispRuntime.h>
#import <Risp/RispLazySequence.h>
#import <Risp/RispNilExpression.h>
#import <Risp/RispTrueExpression.h>
#import <Risp/RispFalseExpression.h>
#import <Risp/RispKeywordExpression.h>
#import <Risp/RispNumberExpression.h>
#import <Risp/RispStringExpression.h>
#import <Risp/RispVectorExpression.h>

#import <objc/runtime.h>

@interface RispBaseParser (Analyze)
+ (id <RispExpression>)analyzeSymbol:(RispSymbol *)symbol;
+ (id <RispExpression>)analyzeSequence:(id <RispSequence>)sequence context:(RispContext *)context name:(NSString *)name;
@end


@implementation RispBaseParser (tag)

+ (RispSymbol *)tagOfObject:(id)o {
    id tag = [o meta][RispMetaKeyTag];
    if ([tag isKindOfClass:[RispSymbol class]]) {
        return tag;
    } else if ([tag isKindOfClass:[NSString class]]) {
        return [RispSymbol named:tag];
    }
    return nil;
}

+ (id)resolveSymbol:(RispSymbol *)symbol allowPrivate:(BOOL)allowPrivate inScope:(RispLexicalScope *)scope {
    if ([[symbol stringValue] rangeOfString:@"."].location > 0 ||
        [[symbol stringValue] characterAtIndex:0] == '[') {
        return [scope objectForKey:symbol];
    }
    return symbol;
}

@end

@implementation RispBaseParser (Analyze)

+ (id <RispExpression>)analyzeSymbol:(RispSymbol *)symbol {
    RispSymbol *tag __unused = [self tagOfObject:symbol];
    return [[RispLiteralExpression alloc] initWithValue:symbol];
}

+ (id <RispExpression>)analyzeSequence:(id <RispSequence>)sequence context:(RispContext *)context name:(NSString *)name {
    [RispContext setCurrentContext:context];
    
    id me = [RispCompiler macroexpand:sequence];
    if (![me isEqualTo:sequence]) {
        return [self analyze:context form:me];
    }
    id op = [me first];
    if (op == nil || [op isEqualTo:[NSNull null]]) {
        [NSException raise:RispIllegalArgumentException format:@"can not call nil"];
    }
    
    RispBaseParser *p = nil;
    if ([op isEqualTo:[RispSymbol FN]]) {
        return [RispFnExpression parse:me context:context];
    } else if ((p = [context specialForKey:op])) {
        return [[p class] parser:sequence context:context];
    } else if ([op isEqualTo:[RispSymbol DO]]) {
        return [RispBodyExpression parser:me context:context];
    }
    return [RispInvokeExpression parser:sequence context:context];
}
@end

@implementation RispBaseParser
+ (id)parser:(id)object context:(RispContext *)context {
    return nil;
}

+ (id <RispExpression>)analyze:(RispContext *)context form:(id)form {
    return [self analyze:context form:form name:@""];
}

+ (id <RispExpression>)analyze:(RispContext *)context form:(id)form name:(NSString *)name {
    @try {
        if ([form isKindOfClass:[RispLazySequence class]]) {
            form = [RispSequence sequence:form];
            if (form == nil)
                form = [RispList empty];
        }
        
        if (form == nil || [form isKindOfClass:[NSNull class]]) {
            return [[[RispNilExpression alloc] init] copyMetaFromObject:form];
        } else if ([form isEqualTo:@"true"]) {
            return [[[RispTrueExpression alloc] init] copyMetaFromObject:form];
        } else if ([form isEqualTo:@"false"]) {
            return [[[RispFalseExpression alloc] init] copyMetaFromObject:form];
        }
        
        Class fclass = [form class];
        if (fclass == [RispSymbol class]) {
            return [self analyzeSymbol:form];
        } else if (fclass == [RispKeyword class]) {
            // register a keyword
            return [context registerKeyword:form];
        } else if ([form isKindOfClass:[NSNumber class]]) {
            return [[[RispNumberExpression alloc] initWithValue:form] copyMetaFromObject:form];
        } else if ([form isKindOfClass:[NSString class]]) {
            return [[[RispStringExpression alloc] initWithValue:form] copyMetaFromObject:form];
        } else if (fclass == [RispVector class]) {
            return [[RispVectorExpression parse:form context:context] copyMetaFromObject:form];
        } else if (fclass == [RispMap class]) {
            return [[RispMapExpression parser:form context:context] copyMetaFromObject:form];
        } else if ([form conformsToProtocol:@protocol(RispSequence)]) {
            return [RispBaseParser analyzeSequence:form context:context name:@""];
        }
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    return nil;
}

@end
