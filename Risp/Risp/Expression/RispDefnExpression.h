//
//  RispDefnExpression.h
//  Risp
//
//  Created by closure on 5/5/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>

@interface RispDefnExpression : RispBaseExpression
@property (nonatomic, strong, readonly) RispSymbol *key;
@property (nonatomic, strong, readonly) id value;

+ (id)parser:(id)object context:(RispContext *)context;
+ (RispSymbol *)speicalKey;
@end
