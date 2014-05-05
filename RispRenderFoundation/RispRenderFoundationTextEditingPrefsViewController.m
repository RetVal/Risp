//
//  RispRenderFoundationTextEditingPrefsViewController.m
//  Fragaria
//
//  Created by Jonathan on 14/09/2012.
//
//

#import "RispRenderFoundationTextEditingPrefsViewController.h"
#import "RispRenderFoundationFramework.h"

@interface RispRenderFoundationTextEditingPrefsViewController ()

@end

@implementation RispRenderFoundationTextEditingPrefsViewController

/*
 
 - init
 
 */
- (id)init {
    self = [super initWithNibName:@"RispRenderFoundationPreferencesTextEditing" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {

    }
    return self;
}

/*
 
 - changeGutterWidth:
 
 */
- (IBAction)changeGutterWidth:(id)sender {
#pragma unused(sender)
    
	/*NSEnumerator *documentEnumerator =  [[[FRACurrentProject documentsArrayController] arrangedObjects] objectEnumerator];
	for (id document in documentEnumerator) {
		[FRAInterface updateGutterViewForDocument:document];
		[[document valueForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:YES recolour:YES];
	}*/
}


@end
