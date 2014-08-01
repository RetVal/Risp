/*
 *  RispRenderFoundationPreferences.h
 *  Fragaria
 *
 *  Created by Jonathan on 06/05/2010.
 *  Copyright 2010 mugginsoft.com. All rights reserved.
 *
 */

// Fragraria preference keys by type

// color data
// [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]]
extern NSString * const RispRenderFoundationPrefsCommandsColourWell;
extern NSString * const RispRenderFoundationPrefsCommentsColourWell;
extern NSString * const RispRenderFoundationPrefsInstructionsColourWell;
extern NSString * const RispRenderFoundationPrefsKeywordsColourWell;
extern NSString * const RispRenderFoundationPrefsAutocompleteColourWell;
extern NSString * const RispRenderFoundationPrefsVariablesColourWell;
extern NSString * const RispRenderFoundationPrefsStringsColourWell;
extern NSString * const RispRenderFoundationPrefsAttributesColourWell;
extern NSString * const RispRenderFoundationPrefsBackgroundColourWell;
extern NSString * const RispRenderFoundationPrefsTextColourWell;
extern NSString * const RispRenderFoundationPrefsGutterTextColourWell;
extern NSString * const RispRenderFoundationPrefsInvisibleCharactersColourWell;
extern NSString * const RispRenderFoundationPrefsHighlightLineColourWell;
extern NSString * const RispRenderFoundationPrefsNumbersColourWell;

// bool
extern NSString * const RispRenderFoundationPrefsColourNumbers;
extern NSString * const RispRenderFoundationPrefsColourCommands;
extern NSString * const RispRenderFoundationPrefsColourComments;
extern NSString * const RispRenderFoundationPrefsColourInstructions;
extern NSString * const RispRenderFoundationPrefsColourKeywords;
extern NSString * const RispRenderFoundationPrefsColourAutocomplete;
extern NSString * const RispRenderFoundationPrefsColourVariables;
extern NSString * const RispRenderFoundationPrefsColourStrings;	
extern NSString * const RispRenderFoundationPrefsColourAttributes;	
extern NSString * const RispRenderFoundationPrefsShowFullPathInWindowTitle;
extern NSString * const RispRenderFoundationPrefsShowLineNumberGutter;
extern NSString * const RispRenderFoundationPrefsSyntaxColourNewDocuments;
extern NSString * const RispRenderFoundationPrefsLineWrapNewDocuments;
extern NSString * const RispRenderFoundationPrefsIndentNewLinesAutomatically;
extern NSString * const RispRenderFoundationPrefsOnlyColourTillTheEndOfLine;
extern NSString * const RispRenderFoundationPrefsShowMatchingBraces;
extern NSString * const RispRenderFoundationPrefsShowInvisibleCharacters;
extern NSString * const RispRenderFoundationPrefsIndentWithSpaces;
extern NSString * const RispRenderFoundationPrefsColourMultiLineStrings;
extern NSString * const RispRenderFoundationPrefsAutocompleteSuggestAutomatically;
extern NSString * const RispRenderFoundationPrefsAutocompleteIncludeStandardWords;
extern NSString * const RispRenderFoundationPrefsAutoSpellCheck;
extern NSString * const RispRenderFoundationPrefsAutoGrammarCheck;
extern NSString * const RispRenderFoundationPrefsSmartInsertDelete;
extern NSString * const RispRenderFoundationPrefsAutomaticLinkDetection;
extern NSString * const RispRenderFoundationPrefsAutomaticQuoteSubstitution;
extern NSString * const RispRenderFoundationPrefsUseTabStops;
extern NSString * const RispRenderFoundationPrefsHighlightCurrentLine;
extern NSString * const RispRenderFoundationPrefsAutomaticallyIndentBraces;
extern NSString * const RispRenderFoundationPrefsAutoInsertAClosingParenthesis;
extern NSString * const RispRenderFoundationPrefsAutoInsertAClosingBrace;
extern NSString * const RispRenderFoundationPrefsShowPageGuide;

// integer
extern NSString * const RispRenderFoundationPrefsGutterWidth;
extern NSString * const RispRenderFoundationPrefsTabWidth;
extern NSString * const RispRenderFoundationPrefsIndentWidth;
extern NSString * const RispRenderFoundationPrefsShowPageGuideAtColumn;	
extern NSString * const RispRenderFoundationPrefsSpacesPerTabEntabDetab;

// float
extern NSString * const RispRenderFoundationPrefsAutocompleteAfterDelay;	

// font data
// [NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Menlo" size:11]]
extern NSString * const RispRenderFoundationPrefsTextFont;

// string
extern NSString * const RispRenderFoundationPrefsSyntaxColouringPopUpString;

#import <RispRenderFoundation/RispRenderFoundationPrefsViewController.h>
#import <RispRenderFoundation/RispRenderFoundationFontsAndColoursPrefsViewController.h>
#import <RispRenderFoundation/RispRenderFoundationTextEditingPrefsViewController.h>

@interface RispRenderFoundationPreferences : NSObject {
    RispRenderFoundationFontsAndColoursPrefsViewController *fontsAndColoursPrefsViewController;
    RispRenderFoundationTextEditingPrefsViewController *textEditingPrefsViewController;
}
+ (void)initializeValues;
+ (RispRenderFoundationPreferences *)sharedInstance;
- (void)changeFont:(id)sender;
- (void)revertToStandardSettings:(id)sender;

@property (readonly) RispRenderFoundationFontsAndColoursPrefsViewController *fontsAndColoursPrefsViewController;
@property (readonly) RispRenderFoundationTextEditingPrefsViewController *textEditingPrefsViewController;

@end



