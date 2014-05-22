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
#import <Risp/RispBlockExpression.h>
#import <Risp/RispInvokeProtocol.h>

@interface RispFnExpression : RispBaseExpression <RispInvokeProtocol, NSCopying>
@property (nonatomic, strong) RispSymbol *name;
@property (nonatomic, strong) RispMethodExpression *variadicMethod;
@property (nonatomic, strong) RispList *methods;
//@property (nonatomic, strong) RispSymbol *name;

+ (RispFnExpression *)parse:(id <RispSequence>)form context:(RispContext *)context;

- (RispMethodExpression *)methodForArguments:(RispVector *)arguments;
- (RispMethodExpression *)methodForCountOfArgument:(NSUInteger)cntOfArguments;

- (id)applyTo:(RispVector *)arguments;

- (id)copyWithZone:(NSZone *)zone;
@end

@interface RispFnExpression (BlockSupport)
+ (instancetype)blockWihObjcBlock:(id (^)(RispVector *arguments))block variadic:(BOOL)isVariadic numberOfArguments:(NSUInteger)numberOfArguments;
- (id)initWithBlock:(id (^)(RispVector *arguments))block variadic:(BOOL)isVariadic numberOfArguments:(NSUInteger)numberOfArguments;
@end
