//
//  RispConstantExpression.m
//  Risp
//
//  Created by closure on 5/13/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispConstantExpression.h"
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"
#import <Risp/RispNilExpression.h>
#import <Risp/RispTrueExpression.h>
#import <Risp/RispFalseExpression.h>
#import <Risp/RispStringExpression.h>
#import <Risp/RispCharSequence.h>

@implementation RispConstantExpression
+ (RispBaseExpression *)parser:(id)object context:(RispContext *)context {
    id v = object;
    if ([object conformsToProtocol:@protocol(RispSequence)]) {
        id <RispSequence> seq = object;
        v = [seq second];
    }
    if (v == nil) {
        return [[[RispNilExpression alloc] init] copyMetaFromObject:object];
    } else if ([v isEqual: @YES]) {
        return [[[RispTrueExpression alloc] init] copyMetaFromObject:object];
    } else if ([v isEqual: @NO]) {
        return [[[RispFalseExpression alloc] init] copyMetaFromObject:object];
    }
    
    if ([v isKindOfClass:[NSNumber class]]) {
        return [RispNumberExpression parser:v context:context];
    } else if ([v isKindOfClass:[NSString class]]) {
        return [RispStringExpression parser:v context:context];
    } else if ([v conformsToProtocol:@protocol(RispSequence)] && [v count] == 0) {
        return [[[RispConstantExpression alloc] initWithValue:[RispSequence empty]] copyMetaFromObject:object];
    }
    if ([v conformsToProtocol:@protocol(RispSequence)]) {
        return [[[RispConstantExpression alloc] initWithValue:[RispRuntime map:v fn:^id(id object) {
            return [RispBaseParser parser:object context:context];
        }]] copyMetaFromObject:object];
    }
    return [[[RispConstantExpression alloc] initWithValue:v] copyMetaFromObject:object];
}

- (BOOL)isSequence {
    return [_constantValue conformsToProtocol:@protocol(RispSequence)];
}

- (BOOL)isRispSequence {
    return [_constantValue  isKindOfClass:[RispSequence class]];
}

- (BOOL)isRispList {
    return [_constantValue isKindOfClass:[RispList class]];
}

- (BOOL)isRispVector {
    return [_constantValue isKindOfClass:[RispVector class]];
}

- (BOOL)isRispCharSequence {
    return [_constantValue isKindOfClass:[RispCharSequence class]];
}


- (id)initWithValue:(id)value {
    if (self = [super init]) {
        _constantValue = value;
        _value = _constantValue;
    }
    return self;
}

- (id)eval {
    return [RispRuntime map:_constantValue fn:^id(id object) {
        return [object eval];
    }];
}

- (NSString *)description {
    return [_constantValue description];
}

- (id)copyWithZone:(NSZone *)zone {
    RispConstantExpression *copy = [[[RispConstantExpression alloc] initWithValue:_constantValue] copyMetaFromObject:self];
    return copy;
}

- (id)copy {
    return [self copyWithZone:nil];
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [RispAbstractSyntaxTree descriptionAppendIndentation:indentation desc:desc];
    if ([self isSequence]) {
        [desc appendFormat:@"%@ - %@\n", [self class], [self rispLocationInfomation]];
        [[self constantValue] enumerateObjectsUsingBlock:^(RispBaseExpression *obj, NSUInteger idx, BOOL *stop) {
            [obj _descriptionWithIndentation:indentation + 1 desc:desc];
        }];
    } else {
        [desc appendFormat:@"%@ - %@ %@\n", [self class], [self description], [self rispLocationInfomation]];
    }
}
@end
