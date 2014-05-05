//
//  RispDotExpression.h
//  Risp
//
//  Created by closure on 4/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>

@interface RispDotExpression : RispBaseExpression
@property (nonatomic, strong, readonly) id target;
@property (nonatomic, assign, readonly) SEL selector;
@property (nonatomic, strong, readonly) RispVector *arguments;
@property (nonatomic, strong, readonly) id <RispSequence> exprs;

+ (id)parser:(id)object context:(RispContext *)context;
- (id)eval;

+ (RispSymbol *)speicalKey;
@end
