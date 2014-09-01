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
#import <Risp/RispSymbolExpression.h>
#import <Risp/RispMethodExpression.h>
#import <Risp/RispBlockExpression.h>
#import <Risp/RispInvokeProtocol.h>
#import <Risp/RispFnProtocol.h>

@interface RispFnExpression : RispBaseExpression <RispFnProtocol, NSCopying>
@property (nonatomic, strong) RispSymbolExpression *name;
@property (nonatomic, strong) RispMethodExpression *variadicMethod;
@property (nonatomic, strong) RispList *methods;
//@property (nonatomic, strong) RispSymbol *name;

+ (RispFnExpression *)parse:(id <RispSequence>)form context:(RispContext *)context;

- (id)applyTo:(RispVector *)arguments;

- (id)copyWithZone:(NSZone *)zone;
@end

@interface RispFnExpression (BlockSupport)
+ (instancetype)blockWihObjcBlock:(id (^)(RispVector *arguments))block variadic:(BOOL)isVariadic numberOfArguments:(NSUInteger)numberOfArguments;
- (id)initWithBlock:(id (^)(RispVector *arguments))block variadic:(BOOL)isVariadic numberOfArguments:(NSUInteger)numberOfArguments;
@end
