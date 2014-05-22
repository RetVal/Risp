//
//  RispBodyExpression.h
//  Risp
//
//  Created by closure on 4/22/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>

@interface RispBodyExpression : RispBaseExpression <NSCopying>
+ (RispBodyExpression *)parser:(id <RispSequence>)form context:(RispContext *)context;

@property (nonatomic, strong, readonly) RispVector *exprs;
@end
