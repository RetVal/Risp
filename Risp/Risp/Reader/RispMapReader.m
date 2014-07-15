//
//  RispMapReader.m
//  Risp
//
//  Created by closure on 5/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispMapReader.h"
#import <Risp/RispMap.h>
#import <Risp/RispReader.h>

@implementation RispMapReader
- (id)invoke:(RispReader *)reader object:(id)object {
    return [RispMap mapWithSequence:[self reader:reader delimited:'}' recursive:YES]];
}
@end
