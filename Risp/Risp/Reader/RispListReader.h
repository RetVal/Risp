//
//  RispListReader.h
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispBaseReader.h"

@class RispReader;
@interface RispListReader : RispBaseReader
- (id)invoke:(RispReader *)reader object:(id)object;
@end
