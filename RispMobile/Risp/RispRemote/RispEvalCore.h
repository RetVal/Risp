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
+ (NSArray *)evalCurrentLine:(NSString *)sender evalResult:(NSDictionary **)dict; // return keys in order
@end

FOUNDATION_EXPORT NSString * RispExpressionKey;
FOUNDATION_EXPORT NSString * RispEvalValueKey;
FOUNDATION_EXPORT NSString * RispExceptionKey;