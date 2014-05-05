//
//  RispMethodExpression.h
//  Risp
//
//  Created by closure on 4/21/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispBaseExpression.h>
#import <Risp/RispSequenceProtocol.h>
#import <Risp/RispContext.h>
#import <Risp/RispInvokeProtocol.h>

@class RispFnExpression;
@interface RispMethodExpression : RispBaseExpression <RispInvokeProtocol>

@property (nonatomic, strong) NSMutableArray *argstypes;
@property (nonatomic, strong) NSString *prim;
@property (nonatomic, strong) RispVector *requiredParms;
@property (nonatomic, strong) RispSymbol *restParm;

@property (nonatomic, assign, readonly, getter = isStatics) BOOL statics;

@property (nonatomic, strong) NSMutableDictionary *localBinding;
+ (RispMethodExpression *)parser:(id <RispSequence>)form context:(RispContext *)context fn:(RispFnExpression *)fn static:(BOOL)isStatic;

- (BOOL)isVariadic;

- (id)applyTo:(RispVector *)arguments;
@end
