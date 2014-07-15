//
//  RispKeywordInvokeExpression.h
//  Risp
//
//  Created by closure on 5/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>

@interface RispKeywordInvokeExpression : RispBaseExpression <RispExpression>
@property (nonatomic, strong, readonly) RispBaseExpression *targetExpression;
@property (nonatomic, strong, readonly) RispKeywordExpression *keywordExpression;
- (id)initWithTargetExpression:(RispBaseExpression *)target keyword:(RispKeywordExpression *)keyword;
@end
