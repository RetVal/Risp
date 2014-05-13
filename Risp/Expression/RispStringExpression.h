//
//  RispStringExpression.h
//  Risp
//
//  Created by closure on 4/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>

@interface RispStringExpression : RispLiteralExpression
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context;
@end
