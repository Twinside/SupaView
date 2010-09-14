//
//  SupaViewAppDelegate.m
//  SupaView
//
//  Created by Vincent Berthoux on 12/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVSupaViewAppDelegate.h"

@implementation SupaViewAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
    curentlyNavigated = nil;
    printf( "sizeof(FileTree) %i\n", (int)sizeof(SVFileTree));
    printf( "sizeof(SVFolderTree) %i\n", (int)sizeof( SVFolderTree ));
    printf( "sizeof(NSString) %i\n", (int)sizeof( NSString ));
    printf( "sizeof(SVLayoutTree) %i\n", (int)sizeof(SVLayoutTree) );
}

- (IBAction)zoomInView:sender { [mainTreeView zoomBy:-0.1f]; }
- (IBAction)zoomOutView:sender { [mainTreeView zoomBy:0.1f]; }

- (IBAction)openDocument: sender
{
    int result;
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
 
    [oPanel setAllowsMultipleSelection:(BOOL)NO];
    [oPanel setCanChooseFiles:NO];
    [oPanel setCanChooseDirectories:YES];

    result = [oPanel runModal];

    if (result == NSFileHandlingPanelOKButton)
    {
        [curentlyNavigated release];
        curentlyNavigated =
            [SVFileTree createFromPath:[oPanel URL]];
        FILE *dot;
        
        dot = fopen( "/Users/vince/Desktop/h.dot", "w" );
        
        SVLayoutTree  *created =
            [curentlyNavigated createLayoutTree];

        [mainTreeView setTreeMap:created];
        [created release];
    }
}

@end
