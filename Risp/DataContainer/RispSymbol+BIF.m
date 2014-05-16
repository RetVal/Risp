//
//  RispSymbol+BIF.m
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispSymbol+BIF.h"

@implementation RispSymbol (BIF)
+ (RispSymbol *)DO {
    return [RispSymbol named:@"do"];
}

+ (RispSymbol *)IDENTITY {
    return [RispSymbol named:@"identity"];
}

+ (RispSymbol *)DOT {
    return [RispSymbol named:@"."];
}

+ (RispSymbol *)FN {
    return [RispSymbol named:@"fn"];
}

+ (RispSymbol *)AMP {
    return [RispSymbol named:@"&"];
}

+ (RispSymbol *)QUOTE {
    return [RispSymbol named:@"quote"];
}

+ (RispSymbol *)APPLY {
    return [RispSymbol named:@"apply"];
}

+ (RispSymbol *)MAP {
    return [RispSymbol named:@"map"];
}

+ (RispSymbol *)REDUCE {
    return [RispSymbol named:@"reduce"];
}

+ (RispSymbol *)UNQUOTE {
    return [RispSymbol named:@"unquote"];
}

+ (RispSymbol *)UNQUOTESPLICING {
    return [RispSymbol named:@"unquote-splicing"];
}
@end
