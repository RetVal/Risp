//
//  RispClosureExpression.h
//  Risp
//
//  Created by closure on 5/22/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>

@interface RispClosureExpression : RispBaseExpression
@property (nonatomic, strong, readonly) RispFnExpression *fnExpression;
@property (nonatomic, strong, readonly) RispLexicalScope *environment;
- (id)initWithLexicalScopeEnvironment:(RispLexicalScope *)environment fnExpression:(RispFnExpression *)fnExpression;
@end
