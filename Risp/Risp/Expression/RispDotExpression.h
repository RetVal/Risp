//
//  RispDotExpression.h
//  Risp
//
//  Created by closure on 4/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispSymbolExpression.h>
#import <Risp/RispSelectorExpression.h>

@interface RispDotExpression : RispBaseExpression
@property (nonatomic, strong, readonly) RispSymbolExpression *targetExpression;
@property (nonatomic, strong, readonly) RispSelectorExpression *selectorExpression;

@property (nonatomic, strong, readonly) id target;      // analyzed target
@property (nonatomic, assign, readonly) SEL selector;   // selector
@property (nonatomic, strong, readonly) id <RispSequence> exprs;
@property (nonatomic, assign, readonly, getter = isClass) BOOL Class;
@property (nonatomic, strong, readonly) NSMethodSignature *methodSignature;
@property (nonatomic, assign, readonly) BOOL evaled;

+ (id)parser:(id)object context:(RispContext *)context;
- (id)eval;

+ (RispSymbol *)speicalKey;
@end
