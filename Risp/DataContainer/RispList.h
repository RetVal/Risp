//
//  RispList.h
//  Risp
//
//  Created by closure on 4/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispSequenceProtocol.h>
#import <Risp/RispSequence.h>

@interface RispList : RispSequence <RispSequence, NSCopying>
+ (id)listWithObjects:(id)object, ... NS_REQUIRES_NIL_TERMINATION;
+ (id)listWithObjectsFromArray:(NSArray *)array;
+ (id)listWithRest:(id <RispSequence>)rest objects:(id)object, ... NS_REQUIRES_NIL_TERMINATION;

- (id)init;
+ (id)empty;

+ (id)creator;
@end

