//
//  RispKBRecorderCell.h
//  ShortcutRecorder
//
//  Copyright 2006-2007 Contributors. All rights reserved.
//
//  License: BSD
//
//  Contributors:
//      David Dauer
//      Jesper
//      Jamie Kirkpatrick

#import <Cocoa/Cocoa.h>
#import <RispKeyboardBinding/RispKBCommon.h>

#define RispKBMinWidth 50
#define RispKBMaxHeight 22

#define RispKBTransitionFPS 30.0f
#define RispKBTransitionDuration 0.35f
//#define RispKBTransitionDuration 2.35
#define RispKBTransitionFrames (RispKBTransitionFPS*RispKBTransitionDuration)
#define RispKBAnimationAxisIsY YES
#define ShortcutRecorderNewStyleDrawing

#define RispKBAnimationOffsetRect(X,Y)	(RispKBAnimationAxisIsY ? NSOffsetRect(X,0.0f,-NSHeight(Y)) : NSOffsetRect(X,NSWidth(Y),0.0f))

@class RispKBRecorderControl, RispKBValidator;

enum RispKBRecorderStyle {
    RispKBGradientBorderStyle = 0,
    RispKBGreyStyle = 1
};
typedef enum RispKBRecorderStyle RispKBRecorderStyle;

@interface RispKBRecorderCell : NSActionCell <NSCoding>
{	
	NSGradient          *recordingGradient;
	NSString            *autosaveName;
	
	BOOL                isRecording;
	BOOL                mouseInsideTrackingArea;
	BOOL                mouseDown;
	
	RispKBRecorderStyle		style;
	
	BOOL				isAnimating;
	CGFloat				transitionProgress;
	BOOL				isAnimatingNow;
	BOOL				isAnimatingTowardsRecording;
	BOOL				comboJustChanged;
	
	NSTrackingRectTag   removeTrackingRectTag;
	NSTrackingRectTag   snapbackTrackingRectTag;
	
	KeyCombo            keyCombo;
	BOOL				hasKeyChars;
	NSString		    *keyChars;
	NSString		    *keyCharsIgnoringModifiers;
	
	NSUInteger        allowedFlags;
	NSUInteger        requiredFlags;
	NSUInteger        recordingFlags;
	
	BOOL				allowsKeyOnly;
	BOOL				escapeKeysRecord;
	
	NSSet               *cancelCharacterSet;
	
    RispKBValidator         *validator;
    
	IBOutlet id         delegate;
	BOOL				globalHotKeys;
	void				*hotKeyModeToken;
}

- (void)resetTrackingRects;

#pragma mark *** Aesthetics ***

+ (BOOL)styleSupportsAnimation:(RispKBRecorderStyle)style;

- (BOOL)animates;
- (void)setAnimates:(BOOL)an;
- (RispKBRecorderStyle)style;
- (void)setStyle:(RispKBRecorderStyle)nStyle;

#pragma mark *** Delegate ***

- (id)delegate;
- (void)setDelegate:(id)aDelegate;

#pragma mark *** Responder Control ***

- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;

#pragma mark *** Key Combination Control ***

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;
- (void)flagsChanged:(NSEvent *)theEvent;

- (NSUInteger)allowedFlags;
- (void)setAllowedFlags:(NSUInteger)flags;

- (NSUInteger)requiredFlags;
- (void)setRequiredFlags:(NSUInteger)flags;

- (BOOL)allowsKeyOnly;
- (void)setAllowsKeyOnly:(BOOL)nAllowsKeyOnly;
- (void)setAllowsKeyOnly:(BOOL)nAllowsKeyOnly escapeKeysRecord:(BOOL)nEscapeKeysRecord;
- (BOOL)escapeKeysRecord;
- (void)setEscapeKeysRecord:(BOOL)nEscapeKeysRecord;

- (BOOL)canCaptureGlobalHotKeys;
- (void)setCanCaptureGlobalHotKeys:(BOOL)inState;

- (KeyCombo)keyCombo;
- (void)setKeyCombo:(KeyCombo)aKeyCombo;

#pragma mark *** Autosave Control ***

- (NSString *)autosaveName;
- (void)setAutosaveName:(NSString *)aName;

// Returns the displayed key combination if set
- (NSString *)keyComboString;

- (NSString *)keyChars;
- (NSString *)keyCharsIgnoringModifiers;

@end

// Delegate Methods
@interface NSObject (RispKBRecorderCellDelegate)
- (BOOL)shortcutRecorderCell:(RispKBRecorderCell *)aRecorderCell isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason;
- (void)shortcutRecorderCell:(RispKBRecorderCell *)aRecorderCell keyComboDidChange:(KeyCombo)newCombo;
@end
