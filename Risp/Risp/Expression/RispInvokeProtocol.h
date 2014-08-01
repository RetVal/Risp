//
//  RispInvokeProtocol.h
//  Risp
//
//  Created by closure on 5/4/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RispVector;
@protocol RispInvokeProtocol <NSObject>
@required
- (id)applyTo:(RispVector *)arguments;
@end
