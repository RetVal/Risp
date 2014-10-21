//
//  RispASTContextRecursiveVisitor.m
//  RispCompiler
//
//  Created by closure on 9/3/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispASTContextRecursiveVisitor.h"
#import <Risp/RispAbstractSyntaxTree.h>

#import <Risp/RispBaseExpression.h>
#import <Risp/RispLiteralExpression.h>
#import <Risp/RispNilExpression.h>
#import <Risp/RispKeywordExpression.h>
#import <Risp/RispNumberExpression.h>
#import <Risp/RispStringExpression.h>
#import <Risp/RispSymbolExpression.h>
#import <Risp/RispSelectorExpression.h>
#import <Risp/RispVectorExpression.h>
#import <Risp/RispFnExpression.h>
#import <Risp/RispTrueExpression.h>
#import <Risp/RispFalseExpression.h>
#import <Risp/RispMethodExpression.h>
#import <Risp/RispInvokeExpression.h>
#import <Risp/RispDefExpression.h>
#import <Risp/RispDefnExpression.h>
#import <Risp/RispDotExpression.h>
#import <Risp/RispBlockExpression.h>
#import <Risp/RispBodyExpression.h>
#import <Risp/RispIfExpression.h>
#import <Risp/RispConstantExpression.h>
#import <Risp/RispMapExpression.h>
#import <Risp/RispLetExpression.h>
#import <Risp/RispKeywordInvokeExpression.h>
#import <Risp/RispClosureExpression.h>

@protocol RispASTContextRecursiveVisitorProtocol <NSObject>

@required
- (BOOL)visit:(BOOL(^)(RispBaseExpression *expr, NSUInteger level))process level:(NSUInteger)level;

@end

@interface RispBaseExpression (RecursiveVisitor) <RispASTContextRecursiveVisitorProtocol>
@end

@implementation RispBaseExpression (RecursiveVistor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    return process(self, level);
}

@end

@implementation RispLiteralExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    return process(self, level);
}

@end

@implementation RispNilExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    return process(self, level);
}

@end

@implementation RispKeywordExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    return process(self, level);
}

@end

@implementation RispNumberExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    return process(self, level);
}

@end

@implementation RispStringExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    return process(self, level);
}

@end

@implementation RispSymbolExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    return process(self, level);
}

@end

@implementation RispSelectorExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    return process(self, level);
}

@end

@implementation RispVectorExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    BOOL continueFlag = [super visit:process level:level];
    if (continueFlag) {
        for (RispBaseExpression *expr in [self vector]) {
            continueFlag = [expr visit:process level:level+1];
            if (!continueFlag) {
                break;
            }
        }
    }
    return YES;
}

@end

@implementation RispFnExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    BOOL continueFlag = [super visit:process level:level];
    if (!continueFlag) {
        return YES;
    }
    continueFlag = [[self name] visit:process level:level+1];
    if (!continueFlag) {
        return YES;
    }
    for (RispBaseExpression *expr in [self methods]) {
        continueFlag = [expr visit:process level:level+1];
        if (!continueFlag) {
            break;
        };
    }
    return YES;
}

@end

@implementation RispTrueExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    return process(self, level);
}

@end

@implementation RispFalseExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    return process(self, level);
}

@end

@implementation RispMethodExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    BOOL continueFlag = [super visit:process level:level];
    if (!continueFlag) {
        return YES;
    }
    for (RispBaseExpression *expr in [[self requiredParms] arguments]) {
        continueFlag = [expr visit:process level:level+1];
        if (!continueFlag) {
            break;
        }
    }
    if (continueFlag) {
        [[self bodyExpression] visit:process level:level+1];
    }
    return YES;
}

@end

@implementation RispInvokeExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    BOOL continueFlag = [super visit:process level:level];
    if (!continueFlag) {
        return YES;
    }
    continueFlag = [[self fexpr] visit:process level:level+1];
    if (!continueFlag) {
        return YES;
    }
    for (RispBaseExpression *expr in [self arguments]) {
        continueFlag = [expr visit:process level:level+1];
        if (!continueFlag) {
            break;
        }
    }
    return YES;
}

@end

@implementation RispBodyExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    BOOL continueFlag = [super visit:process level:level];
    if (!continueFlag) {
        return YES;
    }
    for (RispBaseExpression *expr in [self exprs]) {
        continueFlag = [expr visit:process level:level+1];
        if (!continueFlag) {
            break;
        }
    }
    return YES;
}

@end

@implementation RispDefExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    BOOL continueFlag = [super visit:process level:level];
    if (!continueFlag) {
        return YES;
    }
    continueFlag = [[self key] visit:process level:level+1];
    if (!continueFlag) {
        return YES;
    }
    [[self value] visit:process level:level+1];
    return YES;
}

@end

@implementation RispDefnExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    BOOL continueFlag = [super visit:process level:level];
    if (!continueFlag) {
        return YES;
    }
    continueFlag = [[self key] visit:process level:level+1];
    if (!continueFlag) {
        return YES;
    }
    [[self value] visit:process level:level+1];
    return YES;
}

@end

@implementation RispDotExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    BOOL continueFlag = [super visit:process level:level];
    if (!continueFlag) {
        return YES;
    }

    continueFlag = [[self targetExpression] visit:process level:level+1];
    if (!continueFlag) {
        return YES;
    }
    [[self selectorExpression] visit:process level:level+1];
    return YES;
}

@end

@implementation RispBlockExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    NSLog(@"not support right now");
    return YES;
}

@end

@implementation RispIfExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    BOOL continueFlag = [super visit:process level:level];
    if (!continueFlag) {
        return YES;
    }
    continueFlag = [[self testExpression] visit:process level:level+1];
    if (!continueFlag) {
        return YES;
    }
    continueFlag = [[self thenExpression] visit:process level:level+1];
    if (!continueFlag) {
        return YES;
    }
    [[self elseExpression] visit:process level:level+1];
    return YES;
}

@end

@implementation RispConstantExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    BOOL continueFlag = [super visit:process level:level];
    if (!continueFlag) {
        return YES;
    }
    [[self constantValue] visit:process level:level+1];
    return YES;
}

@end

@implementation RispMapExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    [super visit:process level:level];
    return YES;
}

@end

@implementation RispLetExpression (RecursiveVisitor)

- (BOOL)visit:(BOOL (^)(RispBaseExpression *, NSUInteger))process level:(NSUInteger)level {
    BOOL continueFlag = [super visit:process level:level];
    if (!continueFlag) {
        return YES;
    }
    continueFlag = [[self bindingExpression] visit:process level:level+1];
    if (!continueFlag) {
        return YES;
    }
    [[self expression] visit:process level:level+1];
    return YES;
}

@end

@interface RispASTContextRecursiveVisitor ()
@property (nonatomic, strong, readonly) RispAbstractSyntaxTree *ast;
@end

@implementation RispASTContextRecursiveVisitor
- (instancetype)initWithAbstractSyntaxTree:(RispAbstractSyntaxTree *)ast {
    if (self = [super init]) {
        _ast = ast;
    }
    return self;
}

- (BOOL)visit:(BOOL (^)(RispBaseExpression *expr, NSUInteger level))process level:(NSUInteger)level {
    RispBaseExpression *expr = [_ast object];
    if (expr && [expr isKindOfClass:[RispBaseExpression class]]) {
        [expr visit:process level:level+1];
    }
    return YES;
}
@end
