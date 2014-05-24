//
//  RispMapExpression.m
//  Risp
//
//  Created by closure on 5/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispMapExpression.h"
#import <Risp/RispMap.h>
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

@interface RispMapExpression ()
@property (nonatomic, strong, readonly) RispVector *keyvals;
@end

@implementation RispMapExpression
+ (id<RispExpression>)parser:(RispMap *)object context:(RispContext *)context {
    NSMutableArray *keyvals = [[NSMutableArray alloc] init];
    NSMutableSet *set = [[NSMutableSet alloc] init];
    BOOL keysConstant = YES;
    BOOL valsConstant = YES;
    BOOL allConstantKeysUnique = YES;
    BOOL evalContext = [context status] == RispContextEval;
    if (!evalContext) {
        [context setStatus:RispContextExpression];
    }
    for (id <RispSequence>s = [object seq]; s; s = [s next]) {
        RispVector *e = [s first];
        
        RispBaseExpression *k = [RispBaseParser analyze:context form:[e first]];
        RispBaseExpression *v = [RispBaseParser analyze:context form:[e second]];
        [keyvals addObject:k];
        [keyvals addObject:v];
        
        if ([k isKindOfClass:[RispLiteralExpression class]]) {
            id kval = [k eval];
            if ([set containsObject:kval]) {
                allConstantKeysUnique = NO;
            } else {
                [set addObject:kval];
            }
        } else {
            keysConstant = NO;
        }
        
        if (valsConstant && ![v isKindOfClass:[RispLiteralExpression class]]) {
            valsConstant = NO;
        }
    }
    if (keysConstant) {
        if(!allConstantKeysUnique) {
            [NSException raise:RispInvalidNumberFormatException format:@"Duplicate constant keys in map"];
        }
        
        if (valsConstant) {
            [keyvals enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                keyvals[idx] = [keyvals[idx] eval];
            }];
            RispMap *map = [RispMap mapWithSequence:[RispVector listWithObjectsFromArrayNoCopy:keyvals]];
            return [[RispConstantExpression alloc] initWithValue:map];
        }
    }
    RispMapExpression *expr = [[RispMapExpression alloc] initWithKeyValues:[RispVector listWithObjectsFromArrayNoCopy:keyvals]];
    return expr;
    return [[RispMapExpression alloc] initWithKeyValues:nil];
}

- (id)initWithKeyValues:(RispVector *)keyvals {
    if (self = [super init]) {
        _keyvals = keyvals;
    }
    return self;
}

- (id)eval {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:[_keyvals count]];
    [_keyvals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [ret addObject:[obj eval]];
    }];
    return [RispMap mapWithSequence:[RispVector listWithObjectsFromArrayNoCopy:ret]];
}

- (id)copyWithZone:(NSZone *)zone {
    RispMapExpression *copy = [[RispMapExpression alloc] initWithKeyValues:_keyvals];
    return copy;
}
@end
