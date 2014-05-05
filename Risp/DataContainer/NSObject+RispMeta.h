//
//  NSObject+RispMeta.h
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispMetaKeyDefinition.h>

@interface NSObject (RispMeta)
- (NSDictionary *)meta;
- (id)withMeta:(id)value forKey:(id)key;
@end
