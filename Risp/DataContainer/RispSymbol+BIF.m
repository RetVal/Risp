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
@end
