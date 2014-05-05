//
//  RispBaseExpression.h
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RispContext;
@protocol RispExpression <NSObject>
@required
+ (id <RispExpression>)parser:(id)object context:(RispContext *)context;
- (id)eval;
@end
@interface RispBaseExpression : NSObject <RispExpression>
- (id)eval;
- (NSString *)description;
@end
