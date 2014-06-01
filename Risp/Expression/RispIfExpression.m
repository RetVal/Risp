//
//  RispIfExpression.m
//  Risp
//
//  Created by closure on 5/13/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispIfExpression.h"
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

@implementation RispIfExpression
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context {
    if (![object conformsToProtocol:@protocol(RispSequence)]) {
        [NSException raise:RispIllegalArgumentException format:@"%@ is not a seq", object];
    }
    id <RispSequence> seq = object;
    if ([seq count] > 4) {
        [NSException raise:RispRuntimeException format:@"Too many arguments to if"];
    } else if ([seq count] < 3) {
        [NSException raise:RispRuntimeException format:@"Too less arguments to if"];
    }
    
    RispContextStatus status = [context status];
    id ifExpression = nil;
    @try {
        RispBaseExpression *testExpression = [RispBaseParser analyze:[context status] == RispContextEval ? context : ([context setStatus:RispContextExpression] , context) form:[seq second]];
        
        RispBaseExpression *thenExpression = [RispBaseParser analyze:context form:[[[seq next] next] first]];
        RispBaseExpression *elseExpression = nil;
        if ([seq count] == 4) {
            elseExpression = [RispBaseParser analyze:context form:[[[[seq next] next] next] first]];
        }
        ifExpression = [[[RispIfExpression alloc] initWithTestExpression:testExpression then:thenExpression else:elseExpression] copyMetaFromObject:object];
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        [context setStatus:status];
    }
    return ifExpression;
}

+ (RispSymbol *)speicalKey {
    return [RispSymbol named:@"if"];
}

- (id)initWithTestExpression:(RispBaseExpression *)testExpression then:(RispBaseExpression *)thenExpression else:(RispBaseExpression *)elseExpression {
    if (self = [super init]) {
        _testExpression = testExpression;
        _thenExpression = thenExpression;
        _elseExpression = elseExpression;
    }
    return self;
}

- (id)eval {
    if ([@YES isEqual:[_testExpression eval]]) {
        return [_thenExpression eval];
    }
    if (_elseExpression)
        return [_elseExpression eval];
    return [NSNull null];
}

- (id)copyWithZone:(NSZone *)zone {
    RispIfExpression *copy = [[RispIfExpression alloc] initWithTestExpression:[_testExpression copy] then:[_thenExpression copy] else:[_elseExpression copy]];
    return copy;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(if %@ %@ %@)", _testExpression, _thenExpression, _elseExpression];
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [super _descriptionWithIndentation:indentation desc:desc];
    [desc appendFormat:@"%@ %@\n", [self class], [self rispLocationInfomation]];
    [_testExpression _descriptionWithIndentation:indentation + 1 desc:desc];
    [_thenExpression _descriptionWithIndentation:indentation + 1 desc:desc];
    [_elseExpression _descriptionWithIndentation:indentation + 1 desc:desc];
}
@end
