//
//  __RispFXNSString.h
//  Risp
//
//  Created by closure on 5/29/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (appendString)
- (id)copyWithAppendString:(NSString *)string;
@end

@interface NSMutableString (appendString)
- (id)copyWithAppendString:(NSString *)string;
@end

@interface NSString (URL)
+ (id)stringWithContentsOfURL:(NSURL *)url;
@end

@interface NSString (File)
+ (id)stringWithContentsOfFile:(NSString *)path;
@end

@interface NSData (Str)
- (NSString *)stringValue;
@end

@interface __RispFXNSString : NSObject

@end
