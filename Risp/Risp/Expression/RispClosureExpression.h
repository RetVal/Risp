//
//  RispClosureExpression.h
//  Risp
//
//  Created by closure on 5/22/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispBaseExpression.h>
#import <Risp/RispInvokeProtocol.h>
#import <Risp/RispFnProtocol.h>
#import <Risp/RispFnExpression.h>

@interface RispClosureExpression : RispBaseExpression <RispFnProtocol>
@property (nonatomic, strong, readonly) RispFnExpression *fnExpression;
@property (nonatomic, strong, readonly) RispLexicalScope *environment;
- (id)initWithLexicalScopeEnvironment:(RispLexicalScope *)environment fnExpression:(RispFnExpression *)fnExpression;
- (RispMethodExpression *)methodForCountOfArgument:(NSUInteger)cntOfArguments;
@end
