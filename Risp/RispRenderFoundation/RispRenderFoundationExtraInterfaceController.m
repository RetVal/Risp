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

#import "RispRenderFoundation.h"
#import "RispRenderFoundationFramework.h"

// class extension
@interface RispRenderFoundationExtraInterfaceController()
@end

@implementation RispRenderFoundationExtraInterfaceController

@synthesize openPanelAccessoryView, openPanelEncodingsPopUp, commandResultWindow, commandResultTextView, projectWindow;

#pragma mark -
#pragma mark Instance methods

/*
 
 - init
 
 */
- (id)init 
{
	self = [super init];
	if (self) {
	}
	
	return self;
}

#pragma mark -
#pragma mark Tabbing
/*
 
 - displayEntab
 
 */

- (void)displayEntab
{
	if (entabWindow == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"RispRenderFoundationEntab.nib" owner:self topLevelObjects:nil];
        
	}
	
	[NSApp beginSheet:entabWindow modalForWindow:RispRenderFoundationCurrentWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}

/*
 
 - displayDetab
 
 */
- (void)displayDetab
{
	if (detabWindow == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"RispRenderFoundationDetab.nib" owner:self topLevelObjects:nil];
	}
	
	[NSApp beginSheet:detabWindow modalForWindow:RispRenderFoundationCurrentWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}


/*
 
 - entabButtonEntabWindowAction:
 
 */
- (IBAction)entabButtonEntabWindowAction:(id)sender
{
	#pragma unused(sender)
	
	[NSApp endSheet:[RispRenderFoundationCurrentWindow attachedSheet]]; 
	[[RispRenderFoundationCurrentWindow attachedSheet] close];
	
	[[RispRenderFoundationTextMenuController sharedInstance] performEntab];
}

/*
 
 - detabButtonDetabWindowAction
 
 */
- (IBAction)detabButtonDetabWindowAction:(id)sender
{
	#pragma unused(sender)
	
	[NSApp endSheet:[RispRenderFoundationCurrentWindow attachedSheet]]; 
	[[RispRenderFoundationCurrentWindow attachedSheet] close];
	
	[[RispRenderFoundationTextMenuController sharedInstance] performDetab];
}

#pragma mark -
#pragma mark Goto 

/*
 
 - cancelButtonEntabDetabGoToLineWindowsAction:
 
 */
- (IBAction)cancelButtonEntabDetabGoToLineWindowsAction:(id)sender
{
	#pragma unused(sender)
	
	NSWindow *window = RispRenderFoundationCurrentWindow;
	[NSApp endSheet:[window attachedSheet]]; 
	[[RispRenderFoundationCurrentWindow attachedSheet] close];
}


/*
 
 - displayGoToLine
 
 */
- (void)displayGoToLine
{
	if (goToLineWindow == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"RispRenderFoundationGoToLine.nib" owner:self topLevelObjects:nil];
	}
	
	[NSApp beginSheet:goToLineWindow modalForWindow:RispRenderFoundationCurrentWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}

/*
 
 - goButtonGoToLineWindowAction
 
 */
- (IBAction)goButtonGoToLineWindowAction:(id)sender
{
	#pragma unused(sender)
	
	[NSApp endSheet:[RispRenderFoundationCurrentWindow attachedSheet]]; 
	[[RispRenderFoundationCurrentWindow attachedSheet] close];
	
	[[RispRenderFoundationTextMenuController sharedInstance] performGoToLine:[lineTextFieldGoToLineWindow integerValue]];
}

#pragma mark -
#pragma mark Panels
/*
 
 - openPanelEncodingsPopUp
 
 */
- (NSPopUpButton *)openPanelEncodingsPopUp
{
	if (openPanelEncodingsPopUp == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"RispRenderFoundationOpenPanelAccessoryView.nib" owner:self topLevelObjects:nil];
	}
	
	return openPanelEncodingsPopUp;
}

/*
 
 - openPanelAccessoryView
 
 */
- (NSView *)openPanelAccessoryView
{
	if (openPanelAccessoryView == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"RispRenderFoundationOpenPanelAccessoryView.nib" owner:self topLevelObjects:nil];
	}
	
	return openPanelAccessoryView;
}

/*
 
 - showRegularExpressionsHelpPanel
 
 */
- (void)showRegularExpressionsHelpPanel
{
	if (regularExpressionsHelpPanel == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"RispRenderFoundationRegularExpressionHelp.nib" owner:self topLevelObjects:nil];
	}
	
	[regularExpressionsHelpPanel makeKeyAndOrderFront:nil];
}

#pragma mark -
#pragma mark Command handling

/*
 
 - commandResultWindow
 
 */
- (NSWindow *)commandResultWindow
{
    if (commandResultWindow == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"RispRenderFoundationCommandResult.nib" owner:self topLevelObjects:nil];
		[commandResultWindow setTitle:COMMAND_RESULT_WINDOW_TITLE];
	}
	
	return commandResultWindow;
}

/*
 
 - commandResultTextView
 
 */
- (NSTextView *)commandResultTextView
{
    if (commandResultTextView == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"RispRenderFoundationCommandResult.nib" owner:self topLevelObjects:nil];
		[commandResultWindow setTitle:COMMAND_RESULT_WINDOW_TITLE];		
	}
	
	return commandResultTextView; 
}

/*
 
 - showCommandResultWindow
 
 */
- (void)showCommandResultWindow
{
	[[self commandResultWindow] makeKeyAndOrderFront:nil];
}

@end
