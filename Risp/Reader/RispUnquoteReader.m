//
//  RispUnquoteReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispUnquoteReader.h"

@implementation RispUnquoteReader
- (id)invoke:(RispReader *)reader object:(id)object {
    return [super invoke:reader object:object];
}
@end
