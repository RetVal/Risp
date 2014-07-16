//
//  RispEvalCore.h
//  Risp
//
//  Created by closure on 7/16/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface RispEvalCore : NSObject
+ (NSArray *)evalCurrentLine:(NSString *)sender expressions:(NSArray **)expressions;
@end
