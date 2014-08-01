//
//  __RispFXNSString.m
//  Risp
//
//  Created by closure on 5/29/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "__RispFXNSString.h"

@implementation NSString (appendString)

- (id)copyWithAppendString:(NSString *)string {
    if (!string)
        return self;
    return [NSString stringWithFormat:@"%@%@", self, string];
}

@end

@implementation NSMutableString (appendString)

- (id)copyWithAppendString:(NSString *)string {
    if (!string)
        return self;
    [self appendString:string];
    return self;
}

@end

@implementation NSString (URL)

+ (id)stringWithContentsOfURL:(NSURL *)url {
    return [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
}

@end

@implementation NSString (File)

+ (id)stringWithContentsOfFile:(NSString *)path {
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

@end

@implementation NSData (Str)
- (NSString *)stringValue {
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}
@end

@implementation __RispFXNSString

@end
