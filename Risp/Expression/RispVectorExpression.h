//
//  RispVectorExpression.h
//  Risp
//
//  Created by closure on 4/21/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispBaseExpression.h>
#import <Risp/RispVector.h>
#import <Risp/RispContext.h>

@interface RispVectorExpression : RispBaseExpression
@property (nonatomic, strong, readonly) RispVector *vector;
+ (RispVectorExpression *)parse:(RispVector *)vector context:(RispContext *)context;
- (id)initWithVector:(RispVector *)vector;
@end
