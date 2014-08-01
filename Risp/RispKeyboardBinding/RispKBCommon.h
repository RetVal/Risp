//
//  RispKBCommon.h
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
#import <Carbon/Carbon.h>
#import <CoreServices/CoreServices.h>

#pragma mark Dummy class 

@interface RispKBDummyClass : NSObject {} @end

#pragma mark -
#pragma mark Typedefs

typedef struct _KeyCombo {
	NSUInteger flags; // 0 for no flags
	NSInteger code; // -1 for no code
} KeyCombo;

#pragma mark -
#pragma mark Enums

// Unicode values of some keyboard glyphs
enum {
	KeyboardTabRightGlyph       = 0x21E5,
	KeyboardTabLeftGlyph        = 0x21E4,
	KeyboardCommandGlyph        = kCommandUnicode,
	KeyboardOptionGlyph         = kOptionUnicode,
	KeyboardShiftGlyph          = kShiftUnicode,
	KeyboardControlGlyph        = kControlUnicode,
	KeyboardReturnGlyph         = 0x2305,
	KeyboardReturnR2LGlyph      = 0x21A9,	
	KeyboardDeleteLeftGlyph     = 0x232B,
	KeyboardDeleteRightGlyph    = 0x2326,	
	KeyboardPadClearGlyph       = 0x2327,
    KeyboardLeftArrowGlyph      = 0x2190,
	KeyboardRightArrowGlyph     = 0x2192,
	KeyboardUpArrowGlyph        = 0x2191,
	KeyboardDownArrowGlyph      = 0x2193,
    KeyboardPageDownGlyph       = 0x21DF,
	KeyboardPageUpGlyph         = 0x21DE,
	KeyboardNorthwestArrowGlyph = 0x2196,
	KeyboardSoutheastArrowGlyph = 0x2198,
	KeyboardEscapeGlyph         = 0x238B,
	KeyboardHelpGlyph           = 0x003F,
	KeyboardUpArrowheadGlyph    = 0x2303,
};

// Special keys
enum {
	kRispKBKeysF1 = 122,
	kRispKBKeysF2 = 120,
	kRispKBKeysF3 = 99,
	kRispKBKeysF4 = 118,
	kRispKBKeysF5 = 96,
	kRispKBKeysF6 = 97,
	kRispKBKeysF7 = 98,
	kRispKBKeysF8 = 100,
	kRispKBKeysF9 = 101,
	kRispKBKeysF10 = 109,
	kRispKBKeysF11 = 103,
	kRispKBKeysF12 = 111,
	kRispKBKeysF13 = 105,
	kRispKBKeysF14 = 107,
	kRispKBKeysF15 = 113,
	kRispKBKeysF16 = 106,
	kRispKBKeysF17 = 64,
	kRispKBKeysF18 = 79,
	kRispKBKeysF19 = 80,
	kRispKBKeysSpace = 49,
	kRispKBKeysDeleteLeft = 51,
	kRispKBKeysDeleteRight = 117,
	kRispKBKeysPadClear = 71,
	kRispKBKeysLeftArrow = 123,
	kRispKBKeysRightArrow = 124,
	kRispKBKeysUpArrow = 126,
	kRispKBKeysDownArrow = 125,
	kRispKBKeysSoutheastArrow = 119,
	kRispKBKeysNorthwestArrow = 115,
	kRispKBKeysEscape = 53,
	kRispKBKeysPageDown = 121,
	kRispKBKeysPageUp = 116,
	kRispKBKeysReturnR2L = 36,
	kRispKBKeysReturn = 76,
	kRispKBKeysTabRight = 48,
	kRispKBKeysHelp = 114
};

#pragma mark -
#pragma mark Macros

// Localization macros, for use in any bundle
#define RispKBLoc(key) RispKBLocalizedString(key, nil)
#define RispKBLocalizedString(key, comment) NSLocalizedStringFromTableInBundle(key, @"ShortcutRecorder", [NSBundle bundleForClass: [RispKBDummyClass class]], comment)

// Image macros, for use in any bundle
//#define RispKBImage(name) [[[NSImage alloc] initWithContentsOfFile: [[NSBundle bundleForClass: [self class]] pathForImageResource: name]] autorelease]
#define RispKBResIndImage(name) [RispKBSharedImageProvider supportingImageWithName:name]
#define RispKBImage(name) RispKBResIndImage(name)

//#define RispKBCommonWriteDebugImagery

// Macros for glyps
#define RispKBInt(x) [NSNumber numberWithInteger:x]
#define RispKBChar(x) [NSString stringWithFormat: @"%C", (unsigned short)x]

// Some default values
#define ShortcutRecorderEmptyFlags 0
#define ShortcutRecorderAllFlags ShortcutRecorderEmptyFlags | (NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask | NSShiftKeyMask | NSFunctionKeyMask)
#define ShortcutRecorderEmptyCode -1

// These keys will cancel the recoding mode if not pressed with any modifier
#define ShortcutRecorderEscapeKey 53
#define ShortcutRecorderBackspaceKey 51
#define ShortcutRecorderDeleteKey 117

#pragma mark -
#pragma mark Getting a string of the key combination

//
// ################### +- Returns string from keyCode like NSEvent's -characters
// #   EXPLANATORY   # | +- Returns string from keyCode like NSEvent's -charactersUsingModifiers
// #      CHART      # | | +- Returns fully readable and localized name of modifier (if modifier given)
// ################### | | | +- Returns glyph of modifier (if modifier given)
// RispKBString...         X - - X
// RispKBReadableString... X - X -
// RispKBCharacter...      - X - -
//
NSString * RispKBStringForKeyCode( NSInteger keyCode );
NSString * RispKBStringForCarbonModifierFlags( NSUInteger flags );
NSString * RispKBStringForCarbonModifierFlagsAndKeyCode( NSUInteger flags, NSInteger keyCode );
NSString * RispKBStringForCocoaModifierFlags( NSUInteger flags );
NSString * RispKBStringForCocoaModifierFlagsAndKeyCode( NSUInteger flags, NSInteger keyCode );
NSString * RispKBReadableStringForCarbonModifierFlagsAndKeyCode( NSUInteger flags, NSInteger keyCode );
NSString * RispKBReadableStringForCocoaModifierFlagsAndKeyCode( NSUInteger flags, NSInteger keyCode );
NSString *RispKBCharacterForKeyCodeAndCarbonFlags(NSInteger keyCode, NSUInteger carbonFlags);
NSString *RispKBCharacterForKeyCodeAndCocoaFlags(NSInteger keyCode, NSUInteger cocoaFlags);

#pragma mark Converting between Cocoa and Carbon modifier flags

NSUInteger RispKBCarbonToCocoaFlags( NSUInteger carbonFlags );
NSUInteger RispKBCocoaToCarbonFlags( NSUInteger cocoaFlags );

#pragma mark -
#pragma mark Animation pace function

CGFloat RispKBAnimationEaseInOut(CGFloat t);

#pragma mark -
#pragma mark Inlines

FOUNDATION_STATIC_INLINE KeyCombo RispKBMakeKeyCombo(NSInteger code, NSUInteger flags) {
	KeyCombo kc;
	kc.code = code;
	kc.flags = flags;
	return kc;
}

FOUNDATION_STATIC_INLINE BOOL RispKBIsSpecialKey(NSInteger keyCode) {
	return (keyCode == kRispKBKeysF1 || keyCode == kRispKBKeysF2 || keyCode == kRispKBKeysF3 || keyCode == kRispKBKeysF4 || keyCode == kRispKBKeysF5 || keyCode == kRispKBKeysF6 || keyCode == kRispKBKeysF7 || keyCode == kRispKBKeysF8 || keyCode == kRispKBKeysF9 || keyCode == kRispKBKeysF10 || keyCode == kRispKBKeysF11 || keyCode == kRispKBKeysF12 || keyCode == kRispKBKeysF13 || keyCode == kRispKBKeysF14 || keyCode == kRispKBKeysF15 || keyCode == kRispKBKeysF16 || keyCode == kRispKBKeysSpace || keyCode == kRispKBKeysDeleteLeft || keyCode == kRispKBKeysDeleteRight || keyCode == kRispKBKeysPadClear || keyCode == kRispKBKeysLeftArrow || keyCode == kRispKBKeysRightArrow || keyCode == kRispKBKeysUpArrow || keyCode == kRispKBKeysDownArrow || keyCode == kRispKBKeysSoutheastArrow || keyCode == kRispKBKeysNorthwestArrow || keyCode == kRispKBKeysEscape || keyCode == kRispKBKeysPageDown || keyCode == kRispKBKeysPageUp || keyCode == kRispKBKeysReturnR2L || keyCode == kRispKBKeysReturn || keyCode == kRispKBKeysTabRight || keyCode == kRispKBKeysHelp);
}

#pragma mark -
#pragma mark Additions

@interface NSAlert( RispKBAdditions )
+ (NSAlert *) alertWithNonRecoverableError:(NSError *)error;
@end

#pragma mark -
#pragma mark Image provider

@interface RispKBSharedImageProvider : NSObject
+ (NSImage *)supportingImageWithName:(NSString *)name;
@end
