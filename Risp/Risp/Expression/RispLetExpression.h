//
//  RispLetExpression.h
//  Risp
//
//  Created by closure on 5/25/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>

@interface RispLetExpression : RispBaseExpression
@property (nonatomic, strong, readonly) RispVectorExpression *bindingExpression;
@property (nonatomic, strong, readonly) RispBaseExpression *expression;
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context;
+ (RispSymbol *)speicalKey;
@end
