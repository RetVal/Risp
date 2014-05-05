//
//  RispWrappingReader.h
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>

@interface RispWrappingReader : RispBaseReader
@property (strong, nonatomic, readonly) RispSymbol *symbol;
- (id)initWithSymbol:(RispSymbol *)symbol;
@end
