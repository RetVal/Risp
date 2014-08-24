//
//  RispBaseExpression.h
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispIRCodeGenerator.h>

@class RispContext, RispBaseExpression;
@protocol RispExpression <NSObject, NSCopying>
@required
+ (RispBaseExpression *)parser:(id)object context:(RispContext *)context;
- (id)eval;
- (id)copyMetaFromObject:(id)object;
@end

@interface RispBaseExpression : NSObject <RispExpression, RispIRCodeGenerator>
- (id)eval;
- (NSString *)description;
@end
