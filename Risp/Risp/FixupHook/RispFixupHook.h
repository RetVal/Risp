//
//  RispFixupHook.h
//  Risp
//
//  Created by closure on 5/12/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RispFixupHook : NSObject
+ (void)hookFromClass:(id)targetClass selector:(SEL)targetSelector withClass:(id)class withSelector:(SEL)selector;
@end
