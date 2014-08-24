//
//  RispMapExpression.h
//  Risp
//
//  Created by closure on 5/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispBaseExpression.h>
#import <Risp/RispContext.h>

@interface RispMapExpression : RispBaseExpression
+ (RispBaseExpression *)parser:(id)object context:(RispContext *)context;
@end
