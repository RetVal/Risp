//
//  RispConstantExpression.h
//  Risp
//
//  Created by closure on 5/13/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>

@interface RispConstantExpression : RispBaseExpression
@property (nonatomic, strong, readonly) id constantValue;
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context;
@end
