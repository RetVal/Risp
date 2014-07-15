//
//  RispKeywordInvokeExpression.m
//  Risp
//
//  Created by closure on 5/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RispKeywordInvokeExpression.h"
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

@implementation RispKeywordInvokeExpression

- (id)initWithTargetExpression:(RispBaseExpression *)target keyword:(RispKeywordExpression *)keyword {
    if (self = [super init]) {
        _targetExpression = target;
        _keywordExpression = keyword;
    }
    return self;
}

- (id)eval {
    RispMap *target = [_targetExpression eval];
    if (![target isKindOfClass:[RispMap class]]) {
        [NSException raise:RispIllegalArgumentException format:@"%@ is not a map", _targetExpression];
    }
    RispKeyword *keyword = [_keywordExpression eval];
    if (![keyword isKindOfClass:[RispKeyword class]]) {
        [NSException raise:RispIllegalArgumentException format:@"%@ is not a keyword", _keywordExpression];
    }
    return [target objectForKey:keyword];
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [RispAbstractSyntaxTree descriptionAppendIndentation:indentation desc:desc];
    [desc appendFormat:@"%@\n", [self className]];
    [_keywordExpression _descriptionWithIndentation:indentation + 1 desc:desc];
    [_targetExpression _descriptionWithIndentation:indentation + 1 desc:desc];
}
@end
