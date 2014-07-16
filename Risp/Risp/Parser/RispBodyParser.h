//
//  RispBodyParser.h
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispBaseParser.h"

@class RispVector;
@interface RispBodyParser : RispBaseParser
@property (nonatomic, strong) RispVector *exprs;
@end
