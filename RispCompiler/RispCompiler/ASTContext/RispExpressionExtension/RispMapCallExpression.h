//
//  RispMapCallExpression.h
//  RispCompiler
//
//  Created by closure on 8/27/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispBaseExpression.h>
#import <Risp/RispInvokeExpression.h>

@interface RispMapCallExpression : RispBaseExpression
+ (RispBaseExpression *)parser:(id)object context:(RispContext *)context;
@end
