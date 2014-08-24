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
        if (symbol) {
            [NSException raise:RispIllegalArgumentException format:@"symbol(%@) is not a RispSymbol!", symbol];
        } else {
            [NSException raise:RispIllegalArgumentException format:@"symbol is nil"];
        }
    }
    if (self = [super init]) {
        _symbol = symbol;
    }
    return [self copyMetaFromObject:symbol];
}

- (id)eval {
    return [_symbol eval];
}

- (NSString *)description {
    return [_symbol description];
}

- (NSString *)stringValue {
    return [_symbol stringValue];
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [RispAbstractSyntaxTree descriptionAppendIndentation:indentation desc:desc];
    [desc appendFormat:@"%@ - %@ %@\n", [self class], [self description], [self rispLocationInfomation]];
}

- (NSUInteger)hash {
    return [_symbol hash] ^ 0x12345678;
}

- (BOOL)isEqualTo:(id)object {
    if (![object isKindOfClass:[RispSymbolExpression class]]) {
        return NO;
    }
    return [_symbol isEqualTo:[object symbol]];
}
@end
