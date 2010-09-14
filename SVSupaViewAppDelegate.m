//
//  SupaViewAppDelegate.m
//  SupaView
//
//  Created by Vincent Berthoux on 12/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVSupaViewAppDelegate.h"

@interface SupaViewAppDelegate (Private)
- (void)commitTree;
- (void)updateView;
@end

@implementation SupaViewAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
    curentlyNavigated = nil;
    printf( "sizeof(FileTree) %i\n", (int)sizeof(SVFileTree));
    printf( "sizeof(SVFolderTree) %i\n", (int)sizeof( SVFolderTree ));
    printf( "sizeof(NSString) %i\n", (int)sizeof( NSString ));
    printf( "sizeof(SVLayoutTree) %i\n", (int)sizeof(SVLayoutTree) );
    printf( "sizeof(NSMutableArray) %i\n", (int)sizeof(NSMutableArray) );
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
        curentlyNavigated = nil;
        
        [scanProgress setIndeterminate:TRUE];
        [scanProgress startAnimation:self];
        // start parrallel crawling asynchronously
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            curentlyNavigated =
                [SVFileTree createFromPath:[oPanel URL]];

            dispatch_async( dispatch_get_main_queue()
                          , ^{[self commitTree];} );
        });
    }
}

@end

@implementation SupaViewAppDelegate (Private)
- (void)commitTree
{
    SVLayoutTree  *created =
        [curentlyNavigated createLayoutTree];

    [mainTreeView setTreeMap:created];
    [created release];
    [scanProgress stopAnimation:self];
}

- (void)updateView
{
    SVLayoutTree  *created =
        [curentlyNavigated createLayoutTree];

    [mainTreeView setTreeMap:created];
    [created release];
}
@end

