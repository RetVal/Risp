//
//  RispNumberReader.h
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispBaseReader.h"

@interface RispNumberReader : RispBaseReader
+ (NSNumber *)matchNumber:(NSString *)s;
@end
