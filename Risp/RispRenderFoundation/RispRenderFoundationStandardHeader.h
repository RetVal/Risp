/*
 
 RispRenderFoundation
 Written by Jonathan Mitchell, jonathan@mugginsoft.com
 Find the latest version at https://github.com/mugginsoft/Fragaria
 
Smultron version 3.6b1, 2009-09-12
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://smultron.sourceforge.net

Copyright 2004-2009 Peter Borg
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#ifdef DEVELOPMENT_STYLE_BUILD
	#define LogBool(bool) NSLog(@"The value of "#bool" is %@", bool ? @"YES" : @"NO")
	#define LogInt(number) NSLog(@"The value of "#number" is %d", number)
	#define LogFloat(number) NSLog(@"The value of "#number" is %f", number)
	#define Log(obj) NSLog(@"The value of "#obj" is %@", obj)
	#define LogChar(characters) NSLog(@#characters)
	#define Start NSDate *then = [NSDate date]
	#define Stop NSLog(@"Time elapsed: %f seconds", [then timeIntervalSinceNow] * -1)
	#define Pos NSLog(@"File=%s line=%d proc=%s", strrchr("/" __FILE__,'/')+1, __LINE__, __PRETTY_FUNCTION__)
#endif


typedef enum {
	RispRenderFoundationDefaultsLineEndings = 0,
	RispRenderFoundationUnixLineEndings = 1,
	RispRenderFoundationMacLineEndings = 2,
	RispRenderFoundationDarkSideLineEndings = 3,
	RispRenderFoundationLeaveLineEndingsUnchanged = 6
} RispRenderFoundationLineEndings;


typedef enum {
	RispRenderFoundationCurrentDocumentScope = 0,
	RispRenderFoundationCurrentProjectScope = 1,
	RispRenderFoundationAllDocumentsScope = 2
} RispRenderFoundationAdvancedFindScope;

typedef enum {
	RispRenderFoundationListView = 0
} RispRenderFoundationView;

typedef enum {
	RispRenderFoundationVirtualProject = 0,
	RispRenderFoundationPermantProject = 1
} RispRenderFoundationWhatKindOfProject;

typedef enum {
	RispRenderFoundationCheckForUpdatesNever = 0,
	RispRenderFoundationCheckForUpdatesDaily = 1,
	RispRenderFoundationCheckForUpdatesWeekly = 2,
	RispRenderFoundationCheckForUpdatesMonthly = 3
} RispRenderFoundationCheckForUpdatesInterval;

typedef enum {
	RispRenderFoundationPreviewHTML = 0,
	RispRenderFoundationPreviewMarkdown = 1,
	RispRenderFoundationPreviewMultiMarkdown = 2,
} RispRenderFoundationPreviewParser;

typedef enum {
	RispRenderFoundationOpenSaveRemember = 0,
	RispRenderFoundationOpenSaveCurrent = 1,
	RispRenderFoundationOpenSaveAlways = 2
} RispRenderFoundationOpenSaveMatrix;

typedef struct _AppleEventSelectionRange {
	short unused1; // 0 (not used)
	short lineNum; // line to select (<0 to specify range)
	long startRange; // start of selection range (if line < 0)
	long endRange; // end of selection range (if line < 0)
	long unused2; // 0 (not used)
	long theDate; // modification date/time
} AppleEventSelectionRange;

typedef enum {
    SmultronSaveErrorEncodingInapplicable = 1,
} RispRenderFoundationErrors;

#define SMULTRON_ERROR_DOMAIN @"org.smultron.Smultron.ErrorDomain"

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#import <SystemConfiguration/SCNetwork.h>

#import <ApplicationServices/ApplicationServices.h>

#import <WebKit/WebKit.h>

#import <QuartzCore/QuartzCore.h>

#import <QuickLook/QuickLook.h>



#import <unistd.h>

#import <unistd.h>
#import <sys/param.h>
#import <sys/mount.h>
#import <sys/xattr.h>



#define OK_BUTTON NSLocalizedString(@"OK", @"OK-button")
#define CANCEL_BUTTON NSLocalizedString(@"Cancel", @"Cancel-button")
#define DELETE_BUTTON NSLocalizedString(@"Delete", @"Delete-button")

#define UNSAVED_STRING NSLocalizedString(@"(unsaved)", @"(unsaved)")
#define AUTHENTICATE_STRING NSLocalizedString(@"Authenticate", @"Authenticate")
#define SAVE_STRING NSLocalizedString(@"Save", @"Save")
#define PREVIEW_STRING NSLocalizedString(@"Preview", @"Preview")
#define FUNCTION_STRING NSLocalizedString(@"Function", @"Function")
#define CLOSE_SPLIT_STRING NSLocalizedString(@"Close Split", @"Close Split")
#define COLLECTION_STRING NSLocalizedString(@"Collection", @"Collection")
#define TRY_TO_AUTHENTICATE_STRING NSLocalizedString(@"If you want you can try to authenticate with an administrators username and password", @"Indicate that if you want you can try to authenticate with an administrators username and password")

#define TRY_SAVING_AT_A_DIFFERENT_LOCATION_STRING NSLocalizedString(@"Please save it at a different location", @"Indicate that they should try to save in a different location")
#define SPLIT_WINDOW_STRING NSLocalizedString(@"Split Window", @"Split Window")

#define IS_NOW_FOLDER_STRING NSLocalizedString(@"You can not save this file because %@ is now a folder", @"Indicate that you can not save this file because %@ is now a folder")
#define NAME_FOR_UNDO_CHANGE_ENCODING NSLocalizedString(@"Change Encoding", @"Name for undo Change Encoding")
#define NAME_FOR_UNDO_CHANGE_LINE_ENDINGS NSLocalizedString(@"Change Line Endings", @"Name for undo Change Line Endings")
#define DONT_LINE_WRAP_STRING NSLocalizedString(@"Don't Line Wrap Text", @"Don't Line Wrap Text")
#define LINE_WRAP_STRING NSLocalizedString(@"Line Wrap Text", @"Line Wrap Text")
#define UNTITLED_PROJECT_NAME NSLocalizedString(@"Untitled project", @"Untitled project")

#define WILL_DELETE_ALL_ITEMS_IN_COLLECTION NSLocalizedStringFromTable(@"This will delete all items in the collection %@. Are you sure you want to continue?", @"Localizable3", @"This will delete all items in the collection %@. Are you sure you want to continue?")
#define NEW_COLLECTION_STRING NSLocalizedStringFromTable(@"New Collection", @"Localizable3", @"New Collection")
#define FILTER_STRING NSLocalizedStringFromTable(@"Filter", @"Localizable3", @"Filter")
#define COMMAND_RESULT_WINDOW_TITLE NSLocalizedStringFromTable(@"Command Result - Smultron", @"Localizable3", @"Command Result - Smultron")
#define FILE_IS_UNWRITABLE_SAVE_STRING NSLocalizedStringFromTable(@"It seems as if the file is unwritable or that you do not have permission to save the file %@", @"Localizable3", @"It seems as if the file is unwritable or that you do not have permission to save the file %@")

#define NO_DOCUMENT_SELECTED_STRING NSLocalizedString(@"No document selected", @"Indicate that no document is selected for the dummy view")

#define SNIPPET_NAME_LENGTH 26

#define ICON_MAX_SIZE 256.0

#define RispRenderFoundationBasic [RispRenderFoundationBasicPerformer sharedInstance]
#define RispRenderFoundationText [RispRenderFoundationTextPerformer sharedInstance]
#define RispRenderFoundationVarious [RispRenderFoundationVariousPerformer sharedInstance]
#define RispRenderFoundationDefaults [[NSUserDefaultsController sharedUserDefaultsController] values]

/*
 
 Target the current instance
 
 */
#define RispRenderFoundationCurrentExtraInterfaceController [[RispRenderFoundation currentInstance] extraInterfaceController]
#define RispRenderFoundationCurrentDocument [[RispRenderFoundation currentInstance] docSpec]
#define RispRenderFoundationCurrentTextView [[RispRenderFoundation currentInstance] textView]
#define RispRenderFoundationCurrentText [[[RispRenderFoundation currentInstance] textView] string]
#define RispRenderFoundationCurrentWindow [[[RispRenderFoundation currentInstance] textView] window]