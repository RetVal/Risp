//
//  RispBodyParser.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispBodyParser.h>
#import <Risp/RispSequence.h>
#import <Risp/RispSymbol.h>
#import <Risp/RispSymbol+BIF.h>
#import <Risp/RispVector.h>
#import <Risp/RispBaseExpression.h>

id EVAL = @"";
id STATEMENT = @"";

@implementation RispBodyParser
+ (id)parseWithContext:(RispContext *)context object:(id)object {
    RispSequence *seq = (RispSequence *)object;
    if ([[RispSymbol DO] isEqualTo:[seq first]]) {
        seq = [seq next];
    }
    RispVector *exprs = [RispVector empty];
    for (; seq; seq = [seq next]) {
        id <RispExpression> e = (context != EVAL && (context == STATEMENT || [seq next] != nil)) ? [self analyze:STATEMENT form:[seq first]] : [self analyze:context form:[seq first]];
        exprs = [exprs cons:e];
    }
    return nil;
}
@end
