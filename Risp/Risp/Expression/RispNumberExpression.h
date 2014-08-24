//
//  RispNumberExpression.h
//  Risp
//
//  Created by closure on 4/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispContext.h>
#import <Risp/RispLiteralExpression.h>

@interface RispNumberExpression : RispLiteralExpression
+ (RispBaseExpression *)parser:(id)object context:(RispContext *)context;
@end
