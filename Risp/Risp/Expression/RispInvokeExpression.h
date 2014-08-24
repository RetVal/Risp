//
//  RispInvokeExpression.h
//  Risp
//
//  Created by closure on 4/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispBaseExpression.h>
#import <Risp/RispVector.h>
#import <Risp/RispContext.h>

@interface RispInvokeExpression : RispBaseExpression
@property (nonatomic, strong, readonly) RispBaseExpression *fexpr;
@property (nonatomic, strong, readonly) RispVector *arguments;
+ (RispInvokeExpression *)parser:(id <RispSequence>)form context:(RispContext *)context;
@end
