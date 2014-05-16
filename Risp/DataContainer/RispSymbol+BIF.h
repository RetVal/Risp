//
//  RispSymbol+BIF.h
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>

@interface RispSymbol (BIF)
+ (RispSymbol *)DO;
+ (RispSymbol *)IDENTITY;
+ (RispSymbol *)DOT;
+ (RispSymbol *)FN;
+ (RispSymbol *)AMP;

+ (RispSymbol *)QUOTE;
+ (RispSymbol *)APPLY;
+ (RispSymbol *)MAP;
+ (RispSymbol *)REDUCE;

+ (RispSymbol *)UNQUOTE;
+ (RispSymbol *)UNQUOTESPLICING;
@end
