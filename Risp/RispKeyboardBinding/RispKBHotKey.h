//
//  RispKBHotKey.h
//  Protein
//
//  Created by Quentin Carnicelli on Sat Aug 02 2003.
//  Copyright (c) 2003 Quentin D. Carnicelli. All rights reserved.
//
//  Contributors:
// 		Andy Kim

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import <RispKeyboardBinding/RispKBKeyCombo.h>

@interface RispKBHotKey : NSObject
{
	NSString*		mIdentifier;
	NSString*		mName;
	RispKBKeyCombo*		mKeyCombo;
	id				mTarget;
	SEL				mAction;

	NSUInteger		mCarbonHotKeyID;
	EventHotKeyRef	mCarbonEventHotKeyRef;
}

- (id)initWithIdentifier: (id)identifier keyCombo: (RispKBKeyCombo*)combo;
- (id)init;

- (void)setIdentifier: (id)ident;
- (id)identifier;

- (void)setName: (NSString*)name;
- (NSString*)name;

- (void)setKeyCombo: (RispKBKeyCombo*)combo;
- (RispKBKeyCombo*)keyCombo;

- (void)setTarget: (id)target;
- (id)target;
- (void)setAction: (SEL)action;
- (SEL)action;

- (NSUInteger)carbonHotKeyID;
- (void)setCarbonHotKeyID: (NSUInteger)hotKeyID;

- (EventHotKeyRef)carbonEventHotKeyRef;
- (void)setCarbonEventHotKeyRef:(EventHotKeyRef)hotKeyRef;

- (void)invoke;

@end
