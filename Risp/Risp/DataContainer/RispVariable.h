//
//  RispVariable.h
//  Risp
//
//  Created by closure on 4/19/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol RispSequence;
@interface RispVariable : NSObject
- (id)applyTo:(id <RispSequence>)seq;
@end
