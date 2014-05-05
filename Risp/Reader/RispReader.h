//
//  RispReader.h
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispBaseReader.h"
#import "RispPushBackReader.h"
@class RispSymbol;
@interface RispReader : RispBaseReader
@property (nonatomic, strong, readonly) RispPushBackReader *reader;
- (id)invoke:(RispReader *)reader object:(id)object;
- (id)readEofIsError:(BOOL)eofIsError eofValue:(id)eofValue isRecursive:(BOOL)recursive;
- (id)interpretToken:(NSString *)token;
- (BOOL)isEnd;
@end
