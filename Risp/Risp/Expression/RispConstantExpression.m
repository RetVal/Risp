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

@implementation RispConstantExpression
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context {
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
    return [[[RispConstantExpression alloc] initWithValue:v] copyMetaFromObject:object];
}

- (id)initWithValue:(id)value {
    if (self = [super init]) {
        _constantValue = value;
    }
    return self;
}

- (id)eval {
    return _constantValue;
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
    [desc appendFormat:@"%@ - %@ %@\n", [self class], [self description], [self rispLocationInfomation]];
}
@end
