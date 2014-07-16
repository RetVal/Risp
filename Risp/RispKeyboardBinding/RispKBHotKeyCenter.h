//
//  RispKBHotKeyCenter.h
//  Protein
//
//  Created by Quentin Carnicelli on Sat Aug 02 2003.
//  Copyright (c) 2003 Quentin D. Carnicelli. All rights reserved.
//
//  Contributors:
//      Quentin D. Carnicelli
//      Finlay Dobbie
//      Vincent Pottier
// 		Andy Kim

#import <Cocoa/Cocoa.h>

@class RispKBHotKey;

@interface RispKBHotKeyCenter : NSObject
{
	NSMutableDictionary*	mHotKeys; //Keys are carbon hot key IDs
	BOOL					mEventHandlerInstalled;
	UInt32					mHotKeyCount; // Used to assign new hot key ID
}

+ (RispKBHotKeyCenter *)sharedCenter;

- (BOOL)registerHotKey: (RispKBHotKey*)hotKey;
- (void)unregisterHotKey: (RispKBHotKey*)hotKey;

- (NSArray*)allHotKeys;
- (RispKBHotKey*)hotKeyWithIdentifier: (id)ident;

- (void)sendEvent: (NSEvent*)event;

@end
