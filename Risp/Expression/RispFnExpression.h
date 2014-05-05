//
//  RispFnExpression.h
//  Risp
//
//  Created by closure on 4/21/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispSymbol.h>
#import <Risp/RispSymbol+BIF.h>
#import <Risp/RispBaseExpression.h>
#import <Risp/RispContext.h>
#import <Risp/RispMethodExpression.h>
#import <Risp/RispInvokeProtocol.h>

@interface RispFnExpression : RispBaseExpression <RispInvokeProtocol>
@property (nonatomic, strong) RispSymbol *name;
@property (nonatomic, strong) RispMethodExpression *variadicMethod;
@property (nonatomic, strong) RispList *methods;
//@property (nonatomic, strong) RispSymbol *name;

+ (RispFnExpression *)parse:(id <RispSequence>)form context:(RispContext *)context;

- (RispMethodExpression *)methodForArguments:(RispVector *)arguments;

- (id)applyTo:(RispVector *)arguments;
@end
