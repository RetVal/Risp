//
//  RispDispatchReader.m
//  Risp
//
//  Created by closure on 5/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispDispatchReader.h>
#import <Risp/RispReader.h>

@implementation RispDispatchReader
- (id)invoke:(RispReader *)reader object:(id)object {
    UniChar ch = [[reader reader] read1];
    if(ch == 0)
        [NSException raise:RispRuntimeException format:@"EOF while reading character"];
    RispBaseReader *dispatchReader = RispDispatchMacros[ch];
    
    // Try the ctor reader first
    if(dispatchReader == nil) {
        [[reader reader] unread:ch];
        id result = [dispatchReader invoke:reader object:object];
        
		if(result != nil) {
			return result;
		} else {
            [NSException raise:RispRuntimeException format:@"No dispatch macro for: %c", (char) ch];
        }
    }
    return [dispatchReader invoke:reader object:object];
}
@end
