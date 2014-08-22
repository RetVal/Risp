//
//  RispSymbolExpression.m
//  Risp
//
//  Created by closure on 8/21/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispSymbolExpression.h"
#import "RispAbstractSyntaxTree.h"

@implementation RispSymbolExpression
+ (id <RispExpression>)parser:(id)object context:(RispContext *)context {
    return [[RispSymbolExpression alloc] initWithSymbol:object];
}

- (instancetype)initWithSymbol:(RispSymbol *)symbol {
    if (symbol == nil || ![symbol isKindOfClass:[RispSymbol class]]) {
        [NSException raise:RispIllegalArgumentException format:@"symbol is not a RispSymbol!"];
    }
    if (self = [super init]) {
        _symbol = symbol;
    }
    return self;
}

- (id)eval {
    return [_symbol eval];
}

- (NSString *)description {
    return [_symbol description];
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [RispAbstractSyntaxTree descriptionAppendIndentation:indentation desc:desc];
    [desc appendFormat:@"%@ - %@ %@\n", [self class], [self description], [self rispLocationInfomation]];
}
@end
