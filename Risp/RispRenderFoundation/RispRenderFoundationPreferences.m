//
//  RispRenderFoundationPreferences.m
//  RRFP
//
//  Created by Jonathan on 14/09/2012.
//
//

#import "RispRenderFoundationPreferences.h"

// colour prefs
// persisted as [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]]
NSString * const RispRenderFoundationPrefsCommandsColourWell = @"RRFPCommandsColourWell";
NSString * const RispRenderFoundationPrefsCommentsColourWell = @"RRFPCommentsColourWell";
NSString * const RispRenderFoundationPrefsInstructionsColourWell = @"RRFPInstructionsColourWell";
NSString * const RispRenderFoundationPrefsKeywordsColourWell = @"RRFPKeywordsColourWell";
NSString * const RispRenderFoundationPrefsAutocompleteColourWell = @"RRFPAutocompleteColourWell";
NSString * const RispRenderFoundationPrefsVariablesColourWell = @"RRFPVariablesColourWell";
NSString * const RispRenderFoundationPrefsStringsColourWell = @"RRFPStringsColourWell";
NSString * const RispRenderFoundationPrefsAttributesColourWell = @"RRFPAttributesColourWell";
NSString * const RispRenderFoundationPrefsNumbersColourWell = @"RRFPNumbersColourWell";
NSString * const RispRenderFoundationPrefsBackgroundColourWell = @"RRFPBackgroundColourWell";
NSString * const RispRenderFoundationPrefsTextColourWell = @"RRFPTextColourWell";
NSString * const RispRenderFoundationPrefsGutterTextColourWell = @"RRFPGutterTextColourWell";
NSString * const RispRenderFoundationPrefsInvisibleCharactersColourWell = @"RRFPInvisibleCharactersColourWell";
NSString * const RispRenderFoundationPrefsHighlightLineColourWell = @"RRFPHighlightLineColourWell";

// bool
NSString * const RispRenderFoundationPrefsColourNumbers = @"RRFPColourNumbers";
NSString * const RispRenderFoundationPrefsColourCommands = @"RRFPColourCommands";
NSString * const RispRenderFoundationPrefsColourComments = @"RRFPColourComments";
NSString * const RispRenderFoundationPrefsColourInstructions = @"RRFPColourInstructions";
NSString * const RispRenderFoundationPrefsColourKeywords = @"RRFPColourKeywords";
NSString * const RispRenderFoundationPrefsColourAutocomplete = @"RRFPColourAutocomplete";
NSString * const RispRenderFoundationPrefsColourVariables = @"RRFPColourVariables";
NSString * const RispRenderFoundationPrefsColourStrings = @"RRFPColourStrings";
NSString * const RispRenderFoundationPrefsColourAttributes = @"RRFPColourAttributes";
NSString * const RispRenderFoundationPrefsShowFullPathInWindowTitle = @"RRFPShowFullPathInWindowTitle";
NSString * const RispRenderFoundationPrefsShowLineNumberGutter = @"RRFPShowLineNumberGutter";
NSString * const RispRenderFoundationPrefsSyntaxColourNewDocuments = @"RRFPSyntaxColourNewDocuments";
NSString * const RispRenderFoundationPrefsLineWrapNewDocuments = @"RRFPLineWrapNewDocuments";
NSString * const RispRenderFoundationPrefsIndentNewLinesAutomatically = @"RRFPIndentNewLinesAutomatically";
NSString * const RispRenderFoundationPrefsOnlyColourTillTheEndOfLine = @"RRFPOnlyColourTillTheEndOfLine";
NSString * const RispRenderFoundationPrefsShowMatchingBraces = @"RRFPShowMatchingBraces";
NSString * const RispRenderFoundationPrefsShowInvisibleCharacters = @"RRFPShowInvisibleCharacters";
NSString * const RispRenderFoundationPrefsIndentWithSpaces = @"RRFPIndentWithSpaces";
NSString * const RispRenderFoundationPrefsColourMultiLineStrings = @"RRFPColourMultiLineStrings";
NSString * const RispRenderFoundationPrefsAutocompleteSuggestAutomatically = @"RRFPAutocompleteSuggestAutomatically";
NSString * const RispRenderFoundationPrefsAutocompleteIncludeStandardWords = @"RRFPAutocompleteIncludeStandardWords";
NSString * const RispRenderFoundationPrefsAutoSpellCheck = @"RRFPAutoSpellCheck";
NSString * const RispRenderFoundationPrefsAutoGrammarCheck = @"RRFPAutoGrammarCheck";
NSString * const RispRenderFoundationPrefsSmartInsertDelete = @"RRFPSmartInsertDelete";
NSString * const RispRenderFoundationPrefsAutomaticLinkDetection = @"RRFPAutomaticLinkDetection";
NSString * const RispRenderFoundationPrefsAutomaticQuoteSubstitution = @"RRFPAutomaticQuoteSubstitution";
NSString * const RispRenderFoundationPrefsUseTabStops = @"RRFPUseTabStops";
NSString * const RispRenderFoundationPrefsHighlightCurrentLine = @"RRFPHighlightCurrentLine";
NSString * const RispRenderFoundationPrefsAutomaticallyIndentBraces = @"RRFPAutomaticallyIndentBraces";
NSString * const RispRenderFoundationPrefsAutoInsertAClosingParenthesis = @"RRFPAutoInsertAClosingParenthesis";
NSString * const RispRenderFoundationPrefsAutoInsertAClosingBrace = @"RRFPAutoInsertAClosingBrace";
NSString * const RispRenderFoundationPrefsShowPageGuide = @"RRFPShowPageGuide";

// integer
NSString * const RispRenderFoundationPrefsGutterWidth = @"RRFPGutterWidth";
NSString * const RispRenderFoundationPrefsTabWidth = @"RRFPTabWidth";
NSString * const RispRenderFoundationPrefsIndentWidth = @"RRFPIndentWidth";
NSString * const RispRenderFoundationPrefsShowPageGuideAtColumn = @"RRFPShowPageGuideAtColumn";
NSString * const RispRenderFoundationPrefsSpacesPerTabEntabDetab = @"RRFPSpacesPerTabEntabDetab";

// float
NSString * const RispRenderFoundationPrefsAutocompleteAfterDelay = @"RRFPAutocompleteAfterDelay";

// font
// persisted as [NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Menlo" size:11]]
NSString * const RispRenderFoundationPrefsTextFont = @"RRFPTextFont";

// string
NSString * const RispRenderFoundationPrefsSyntaxColouringPopUpString = @"RRFPSyntaxColouringPopUpString";

static BOOL RispRenderFoundation_preferencesInitialized = NO;
static id sharedInstance = nil;

@implementation RispRenderFoundationPreferences

@synthesize fontsAndColoursPrefsViewController, textEditingPrefsViewController;

/*
 
 - initializeValues
 
 */
+ (void)initializeValues
{
	if (RispRenderFoundation_preferencesInitialized) {
		return;
	}
    
    // add to initial values
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];	
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[defaultsController initialValues]];
	
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.031f green:0.0f blue:0.855f alpha:1.0f]] forKey:RispRenderFoundationPrefsCommandsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.0f green:0.45f blue:0.0f alpha:1.0f]] forKey:RispRenderFoundationPrefsCommentsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.45f green:0.45f blue:0.45f alpha:1.0f]] forKey:RispRenderFoundationPrefsInstructionsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.737f green:0.0f blue:0.647f alpha:1.0f]] forKey:RispRenderFoundationPrefsKeywordsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.84f green:0.41f blue:0.006f alpha:1.0f]] forKey:RispRenderFoundationPrefsAutocompleteColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.73f green:0.0f blue:0.74f alpha:1.0f]] forKey:RispRenderFoundationPrefsVariablesColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.804f green:0.071f blue:0.153f alpha:1.0f]] forKey:RispRenderFoundationPrefsStringsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.50f green:0.5f blue:0.2f alpha:1.0f]] forKey:RispRenderFoundationPrefsAttributesColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.031f green:0.0f blue:0.855f alpha:1.0f]] forKey:RispRenderFoundationPrefsNumbersColourWell];
    
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsColourNumbers];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsColourCommands];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsColourInstructions];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsColourKeywords];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:RispRenderFoundationPrefsColourAutocomplete];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsColourVariables];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsColourStrings];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsColourAttributes];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsColourComments];
	
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]] forKey:RispRenderFoundationPrefsBackgroundColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor textColor]] forKey:RispRenderFoundationPrefsTextColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0.42f alpha:1.0f]] forKey:RispRenderFoundationPrefsGutterTextColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor orangeColor]] forKey:RispRenderFoundationPrefsInvisibleCharactersColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.96f green:0.96f blue:0.71f alpha:1.0f]] forKey:RispRenderFoundationPrefsHighlightLineColourWell];
	
	[dictionary setValue:[NSNumber numberWithInteger:40] forKey:RispRenderFoundationPrefsGutterWidth];
	[dictionary setValue:[NSNumber numberWithInteger:4] forKey:RispRenderFoundationPrefsTabWidth];
	[dictionary setValue:[NSNumber numberWithInteger:4] forKey:RispRenderFoundationPrefsIndentWidth];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:RispRenderFoundationPrefsShowPageGuide];
	[dictionary setValue:[NSNumber numberWithInteger:80] forKey:RispRenderFoundationPrefsShowPageGuideAtColumn];
	[dictionary setValue:[NSNumber numberWithFloat:1.0f] forKey:RispRenderFoundationPrefsAutocompleteAfterDelay];
	
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Menlo" size:11]] forKey:RispRenderFoundationPrefsTextFont];
	
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsShowFullPathInWindowTitle];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:RispRenderFoundationPrefsShowLineNumberGutter];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsSyntaxColourNewDocuments];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsLineWrapNewDocuments];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsIndentNewLinesAutomatically];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsOnlyColourTillTheEndOfLine];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsShowMatchingBraces];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:RispRenderFoundationPrefsShowInvisibleCharacters];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:RispRenderFoundationPrefsIndentWithSpaces];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:RispRenderFoundationPrefsColourMultiLineStrings];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsAutocompleteSuggestAutomatically];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:RispRenderFoundationPrefsAutocompleteIncludeStandardWords];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:RispRenderFoundationPrefsAutoSpellCheck];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:RispRenderFoundationPrefsAutoGrammarCheck];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:RispRenderFoundationPrefsSmartInsertDelete];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsAutomaticLinkDetection];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:RispRenderFoundationPrefsAutomaticQuoteSubstitution];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsUseTabStops];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:RispRenderFoundationPrefsHighlightCurrentLine];
	[dictionary setValue:[NSNumber numberWithInteger:4] forKey:RispRenderFoundationPrefsSpacesPerTabEntabDetab];
	
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:RispRenderFoundationPrefsAutomaticallyIndentBraces];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:RispRenderFoundationPrefsAutoInsertAClosingParenthesis];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:RispRenderFoundationPrefsAutoInsertAClosingBrace];
	[dictionary setValue:@"Standard" forKey:RispRenderFoundationPrefsSyntaxColouringPopUpString];
	
	[defaultsController setInitialValues:dictionary];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
	
	RispRenderFoundation_preferencesInitialized = YES;
}

/*
 
 + sharedInstance
 
 */
+ (RispRenderFoundationPreferences *)sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

/*
 
 + allocWithZone:
 
 alloc with zone for singleton
 
 */
+ (id)allocWithZone:(NSZone *)zone
{
#pragma unused(zone)
	return [self sharedInstance];
}

#pragma mark -
#pragma mark Instance methods

/*
 
 - init
 
 */
- (id)init
{
    if (sharedInstance) return sharedInstance;
    self = [super init];
    if (self) {
        // load view controllers
        textEditingPrefsViewController = [[RispRenderFoundationTextEditingPrefsViewController alloc] init];
        fontsAndColoursPrefsViewController = [[RispRenderFoundationFontsAndColoursPrefsViewController alloc] init];
    }
    sharedInstance = self;
    return self;
}

/*
 
 - changeFont:
 
 */
- (void)changeFont:(id)sender
{
    /* NSFontManager will send this method up the responder chain */
    [fontsAndColoursPrefsViewController changeFont:sender];
}

/*
 
 - revertToStandardSettings:
 
 */
- (void)revertToStandardSettings:(id)sender
{
    #pragma unused(sender)
    
	[[NSUserDefaultsController sharedUserDefaultsController] revertToInitialValues:nil];
}
@end

