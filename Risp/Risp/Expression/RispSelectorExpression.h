//
//  RispSelectorExpression.h
//  Risp
//
//  Created by closure on 8/22/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispLiteralExpression.h>
#import <Risp/RispSymbol.h>
#import <Risp/RispContext.h>

@interface RispSelectorExpression : RispLiteralExpression
+ (RispSelectorExpression *)parser:(id)object context:(RispContext *)context;
- (id)eval;
- (NSString *)description;
- (NSString *)stringValue;
@end
