//
//  RispArgumentExpression.h
//  Risp
//
//  Created by closure on 9/4/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispBaseExpression.h>
#import <Risp/RispContext.h> 

@interface RispArgumentExpression : RispBaseExpression
@property (nonatomic, strong, readonly) RispVector *arguments;
+ (RispBaseExpression *)parser:(id)object context:(RispContext *)context;
- (instancetype)initWithArguments:(RispVector *)arguments;
@end
