//
//  RispRenderFoundationBreakpointDelegate.h
//  Fragaria
//
//  Created by Viktor Lidholt on 3/5/13.
//
//

#import <Foundation/Foundation.h>

@protocol RispRenderFoundationBreakpointDelegate <NSObject>

- (void) toggleBreakpointForFile:(NSString*)file onLine:(int)line;
- (NSSet*) breakpointsForFile:(NSString*)file;

@end
