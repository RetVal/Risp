//
//  RispConstantExpression.h
//  Risp
//
//  Created by closure on 5/13/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispContext.h>
#import <Risp/RispLiteralExpression.h>

@interface RispConstantExpression : RispLiteralExpression
@property (nonatomic, strong, readonly) id constantValue;
+ (RispBaseExpression *)parser:(id)object context:(RispContext *)context;

- (BOOL)isSequence;
@end
