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
#import <Risp/RispSymbolExpression.h>
#import <Risp/RispArgumentExpression.h>

@class RispFnExpression, RispBodyExpression;
@interface RispMethodExpression : RispBaseExpression <RispInvokeProtocol, NSCopying>

@property (nonatomic, strong, readonly) RispBodyExpression *bodyExpression;
@property (nonatomic, strong) NSMutableArray *captures;
@property (nonatomic, strong) NSString *prim;
@property (nonatomic, strong) RispArgumentExpression *requiredParms;
@property (nonatomic, strong) RispSymbolExpression *restParm;

@property (nonatomic, assign, readonly, getter = isStatics) BOOL statics;

@property (nonatomic, strong) RispLexicalScope *localBinding;
+ (RispMethodExpression *)parser:(id <RispSequence>)form context:(RispContext *)context fn:(RispFnExpression *)fn static:(BOOL)isStatic;

+ (void)bindArguments:(RispVector *)arguments forMethod:(RispMethodExpression *)method toScope:(RispLexicalScope *)scope;

- (NSInteger)paramsCount;
- (BOOL)isVariadic;

- (id)applyTo:(RispVector *)arguments;
@end
