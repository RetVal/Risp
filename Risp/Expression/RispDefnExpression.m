//
//  RispDefnExpression.m
//  Risp
//
//  Created by closure on 5/5/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispDefnExpression.h"
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

@implementation RispDefnExpression
+ (id)parser:(id <RispSequence>)object context:(RispContext *)context {
    object = [object next];
    if ([[context currentScope] depth] != 0) {
        [NSException raise:RispIllegalArgumentException format:@"def must be use at root frame"];
    }
    if (![[object first] isKindOfClass:[RispSymbol class]]) {
        [NSException raise:RispIllegalArgumentException format:@"%@ is not be symbol", [object first]];
    }
    [context setStatus:RispContextStatement];
    RispFnExpression *fn = [RispFnExpression parse:[[object next] cons:[RispSymbol FN]] context:context];
    return [[RispDefnExpression alloc] initWithValue:fn forKey:[object first]];
}

- (id)initWithValue:(RispFnExpression *)fn forKey:(RispSymbol *)symbol {
    if (self = [super init]) {
        _key = symbol;
        _value = fn;
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
    return [RispSymbol named:@"defn"];
}

- (id)copyWithZone:(NSZone *)zone {
    RispDefnExpression *copy = [[RispDefnExpression alloc] initWithValue:_value forKey:_key];
    return copy;
}
@end
