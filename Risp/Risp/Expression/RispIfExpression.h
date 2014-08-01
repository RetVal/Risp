//
//  RispIfExpression.h
//  Risp
//
//  Created by closure on 5/13/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>

@interface RispIfExpression : RispBaseExpression 
@property (nonatomic, strong, readonly) RispBaseExpression *testExpression;
@property (nonatomic, strong, readonly) RispBaseExpression *thenExpression;
@property (nonatomic, strong, readonly) RispBaseExpression *elseExpression;

+ (id<RispExpression>)parser:(id)object context:(RispContext *)context;
+ (RispSymbol *)speicalKey;
@end
