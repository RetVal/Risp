//
//  RispDefExpression.m
//  Risp
//
//  Created by closure on 4/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispDefExpression.h>
@implementation RispDefExpression
+ (id)parser:(id <RispSequence>)object context:(RispContext *)context {
    object = [object next];
    if ([[context currentScope] depth] != 0) {
        [NSException raise:RispIllegalArgumentException format:@"def must be use at root frame"];
    } else if ([object count] != 2) {
        [NSException raise:RispIllegalArgumentException format:@"def count is not be 2"];
    }
    if (![[object first] isKindOfClass:[RispSymbol class]]) {
        [NSException raise:RispIllegalArgumentException format:@"%@ is not be symbol", [object first]];
    }
    [context setStatus:RispContextEval];
    return [[RispDefExpression alloc] initWithValue:[RispBaseParser analyze:context form:[object second]] forKey:[object first]];
}

- (id)initWithValue:(id)value forKey:(RispSymbol *)symbol {
    if (self = [super init]) {
        _key = symbol;
        _value = value;
    }
    return self;
}

- (id)eval {
    if ([[[RispContext currentContext] currentScope] depth] == 0) {
        [[RispContext currentContext] currentScope][_key] = [_value eval];
        return _key;
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
@end
