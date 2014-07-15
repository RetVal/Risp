//
//  RispKBHotKey.m
//  Protein
//
//  Created by Quentin Carnicelli on Sat Aug 02 2003.
//  Copyright (c) 2003 Quentin D. Carnicelli. All rights reserved.
//

#import <RispKeyboardBinding/RispKBHotKey.h>

#import <RispKeyboardBinding/RispKBHotKeyCenter.h>
#import <RispKeyboardBinding/RispKBKeyCombo.h>

@implementation RispKBHotKey

- (id)init
{
	return [self initWithIdentifier: nil keyCombo: nil];
}

- (id)initWithIdentifier: (id)identifier keyCombo: (RispKBKeyCombo*)combo
{
	self = [super init];

	if( self )
	{
		[self setIdentifier: identifier];
		[self setKeyCombo: combo];
	}

	return self;
}


- (NSString*)description
{
	return [NSString stringWithFormat: @"<%@: %@, %@>", NSStringFromClass( [self class] ), [self identifier], [self keyCombo]];
}

#pragma mark -

- (void)setIdentifier: (id)ident
{
	mIdentifier = ident;
}

- (id)identifier
{
	return mIdentifier;
}

- (void)setKeyCombo: (RispKBKeyCombo*)combo
{
	if( combo == nil )
		combo = [RispKBKeyCombo clearKeyCombo];

	mKeyCombo = combo;
}

- (RispKBKeyCombo*)keyCombo
{
	return mKeyCombo;
}

- (void)setName: (NSString*)name
{
	mName = name;
}

- (NSString*)name
{
	return mName;
}

- (void)setTarget: (id)target
{
	mTarget = target;
}

- (id)target
{
	return mTarget;
}

- (void)setAction: (SEL)action
{
	mAction = action;
}

- (SEL)action
{
	return mAction;
}

- (NSUInteger)carbonHotKeyID
{
	return mCarbonHotKeyID;
}

- (void)setCarbonHotKeyID: (NSUInteger)hotKeyID;
{
	mCarbonHotKeyID = hotKeyID;
}

- (EventHotKeyRef)carbonEventHotKeyRef
{
	return mCarbonEventHotKeyRef;
}

- (void)setCarbonEventHotKeyRef: (EventHotKeyRef)hotKeyRef
{
	mCarbonEventHotKeyRef = hotKeyRef;
}

#pragma mark -

- (void)invoke
{
	[mTarget performSelector: mAction withObject: self];
}

@end
