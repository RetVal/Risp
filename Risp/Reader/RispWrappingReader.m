//
//  RispWrappingReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispWrappingReader.h"

@implementation RispWrappingReader
- (id)initWithSymbol:(RispSymbol *)symbol {
    if (self = [super init]) {
        _symbol = symbol;
    }
    return self;
}

- (id)invoke:(RispReader *)reader object:(id)object {
    id o = [reader readEofIsError:YES eofValue:nil isRecursive:YES];
    return [[RispList alloc] initWithArray:[NSArray arrayWithObjects:_symbol, o, nil]];
}
@end
