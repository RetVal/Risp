//
//  RispAutoHideWindow.h
//  Risp
//
//  Created by closure on 4/25/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@interface NSTrackingArea (updateRect)
- (void)_updateRect:(NSRect)range;
@end

@interface RispAutoHideWindow : NSWindow

@end
