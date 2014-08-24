//
//  RispDefExpression.h
//  Risp
//
//  Created by closure on 4/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispSymbolExpression.h>

@interface RispDefExpression : RispBaseExpression
@property (nonatomic, strong, readonly) RispSymbolExpression *key;
@property (nonatomic, strong, readonly) RispBaseExpression *value;

+ (id)parser:(id)object context:(RispContext *)context;
+ (RispSymbol *)speicalKey;
@end
