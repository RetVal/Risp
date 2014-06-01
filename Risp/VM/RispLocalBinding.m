//
//  RispLocalBinding.m
//  Risp
//
//  Created by closure on 4/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispLocalBinding.h>
#import <Risp/RispSymbol.h>

@implementation RispLocalBinding
- (id)initWithIndex:(NSInteger)index symbol:(RispSymbol *)sym tag:(RispSymbol *)tag init:(RispBaseExpression *)expr isArg:(BOOL)isArg pathNode:(NSTreeNode *)clearPathRoot {
    if (self = [super init]) {
        _idx = index;
        _sym = sym;
        _tag = tag;
        _expr = expr;
        _isArg = isArg;
        _clearPathRoot = clearPathRoot;
        _name = [_sym stringValue];
    }
    return self;
}

@end
