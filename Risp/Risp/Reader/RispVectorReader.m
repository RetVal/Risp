//
//  RispVectorReader.m
//  Risp
//
//  Created by closure on 4/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispVectorReader.h"
#import <Risp/RispVector.h>
#import <Risp/RispList.h>
#import <Risp/RispReader.h>

@implementation RispVectorReader
- (id)invoke:(RispReader *)reader object:(id)object {
    return [[RispVector alloc] initWithArrayNoCopy:[[self reader:reader delimited:']' recursive:YES] array]];
}
@end

