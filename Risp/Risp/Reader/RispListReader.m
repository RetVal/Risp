//
//  RispListReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispListReader.h>
#import <Risp/RispList.h>
#import <Risp/RispPushBackReader.h>
#import <Risp/RispRuntime.h>
#import <Risp/RispReader.h>

@implementation RispListReader
- (id)invoke:(RispReader *)reader object:(id)object {
    RispList *list = [self reader:reader delimited:')' recursive:YES];
    if ([list isEmpty]) {
        return [RispList empty];
    }
    return list;
}
@end
