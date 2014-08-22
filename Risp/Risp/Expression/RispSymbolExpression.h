//
//  RispSymbolExpression.h
//  Risp
//
//  Created by closure on 8/21/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispSymbol.h>
#import <Risp/RispBaseExpression.h>
#import <Risp/RispContext.h>

@interface RispSymbolExpression : RispBaseExpression
@property (nonatomic, strong,readonly) RispSymbol *symbol;
+ (RispSymbolExpression *)parser:(id)object context:(RispContext *)context;
- (instancetype)initWithSymbol:(RispSymbol *)symbol;
- (id)eval;
- (NSString *)description;
@end
