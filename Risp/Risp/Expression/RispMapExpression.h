//
//  RispMapExpression.h
//  Risp
//
//  Created by closure on 5/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>

@interface RispMapExpression : RispBaseExpression
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context;
@end
