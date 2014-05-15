//
//  RispMap.h
//  Risp
//
//  Created by closure on 5/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RispMap : NSObject <RispSequence, NSCopying>
+ (instancetype)mapWithSequence:(id <RispSequence>)seq;
- (id <RispSequence>)seq;
@end
