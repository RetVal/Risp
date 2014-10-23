//
//  RispDefExpression.m
//  Risp
//
//  Created by closure on 4/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispDefExpression.h>
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"
#import "RispBaseParser.h"

@implementation RispDefExpression
+ (id)parser:(id <RispSequence>)object context:(RispContext *)context {
    object = [object next];
    if ([[context currentScope] depth] != 0) {
        if (![[context currentScope] type] & RispLoadFileScope) {
            [NSException raise:RispIllegalArgumentException format:@"def must be use at root frame"];
        }
    } else if ([object count] != 2) {
        [NSException raise:RispIllegalArgumentException format:@"def count is not be 2"];
    }
    if (![[object first] isKindOfClass:[RispSymbol class]]) {
        [NSException raise:RispIllegalArgumentException format:@"%@ is not be symbol", [object first]];
    }
    [context setStatus:RispContextEval];
    return [[RispDefExpression alloc] initWithValue:[RispBaseParser analyze:context form:[object second]] forKey:[RispSymbolExpression parser:[object first] context:context]];
}

- (id)initWithValue:(RispBaseExpression *)value forKey:(RispSymbolExpression *)symbolExpression {
    if (self = [super init]) {
        _key = symbolExpression;
        _value = value;
    }
    return self;
}

- (id)eval {
    if ([[[RispContext currentContext] currentScope] depth] == 0 || [[[RispContext currentContext] currentScope] type] & RispLoadFileScope) {
        RispLexicalScope *scope = [[RispContext currentContext] currentScope];
        if ([[[RispContext currentContext] currentScope] type] & RispLoadFileScope) {
            scope = [scope root];
        }
        scope[[_key symbol]] = [_value eval];
        return [_key symbol];
    }
    [NSException raise:RispIllegalArgumentException format:@"def must be use at root frame"];
    return nil;
}

+ (RispSymbol *)speicalKey {
    return [RispSymbol named:@"def"];
}

- (id)copyWithZone:(NSZone *)zone {
    RispDefExpression *copy = [[RispDefExpression alloc] initWithValue:_value forKey:_key];
    return copy;
}

-(void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [super _descriptionWithIndentation:indentation desc:desc];
    [desc appendFormat:@"%@\n", [self class]];
    [_key _descriptionWithIndentation:indentation + 1 desc:desc];
    [_value _descriptionWithIndentation:indentation + 1 desc:desc];
}
@end
