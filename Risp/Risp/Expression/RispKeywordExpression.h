//
//  RispKeywordExpression.h
//  Risp
//
//  Created by closure on 4/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispLiteralExpression.h>
#import <Risp/RispKeyword.h>

@interface RispKeywordExpression : RispLiteralExpression
+ (id<RispExpression>)parser:(id)object context:(RispContext *)context;
- (id)initWithKeyword:(RispKeyword *)keyword;
@end
