//
//  RispBlockExpression.h
//  Risp
//
//  Created by closure on 5/8/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>
#import <Risp/RispInvokeProtocol.h>

@interface RispBlockExpression : RispMethodExpression <RispInvokeProtocol>
@property (nonatomic, strong, readonly) id (^block)(RispVector *arguments);
@property (nonatomic, assign, readonly) NSUInteger numberOfArguments;
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context;
+ (id<RispExpression>)blockWihObjcBlock:(id (^)(RispVector *arguments))block variadic:(BOOL)isVariadic numberOfArguments:(NSUInteger)numberOfArguments;
- (id)initWithBlock:(id (^)(RispVector *arguments))block variadic:(BOOL)isVariadic numberOfArguments:(NSUInteger)numberOfArguments;
- (id)applyTo:(RispVector *)arguments;
- (BOOL)isVariadic;
- (NSInteger)paramsCount;
@end
