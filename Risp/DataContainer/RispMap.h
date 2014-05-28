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

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;

- (id)objectForKeyedSubscript:(id)key NS_AVAILABLE(10_8, 6_0);
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key NS_AVAILABLE(10_8, 6_0);
@end
