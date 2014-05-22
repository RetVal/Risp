//
//  RispFnProtocol.h
//  Risp
//
//  Created by closure on 5/22/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispInvokeProtocol.h>

@class RispMethodExpression, RispVector;
@protocol RispFnProtocol <RispInvokeProtocol, NSObject>
@required
- (RispMethodExpression *)methodForCountOfArgument:(NSUInteger)cntOfArguments;

@optional
- (RispMethodExpression *)methodForArguments:(RispVector *)arguments;
@end

