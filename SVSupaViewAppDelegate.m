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
    scannedUrl = nil;
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
        scannedElementCount = 0;

        [curentlyNavigated release];
        curentlyNavigated = nil;
        [scannedUrl release];
        scannedUrl = nil;
        
        [scanProgress setIndeterminate:TRUE];
        [scanProgress startAnimation:self];
        scannedUrl = [oPanel URL];
        [scannedUrl retain];

        // start parrallel crawling asynchronously
        curentlyNavigated =
            [SVFileTree createFromPath:scannedUrl
                        updateReceiver:self
                           endNotifier:^{[self commitTree];}];
    }
}

- (void)notifyFileScanned
{
    scannedElementCount++;
    if ( scannedElementCount % 1000 == 0 )
    {
        dispatch_async( dispatch_get_main_queue()
                      , ^{ [self updateView]; } );
    }
}
@end

@implementation SupaViewAppDelegate (Private)
- (void)commitTree
{
    SVLayoutTree  *created =
        [curentlyNavigated createLayoutTree];

    [mainTreeView setTreeMap:created
                       atUrl:scannedUrl];
    [created release];
    [scanProgress stopAnimation:self];
}

- (void)updateView
{
    SVLayoutTree  *created =
        [curentlyNavigated createLayoutTree];

    [mainTreeView setTreeMap:created
                       atUrl:scannedUrl];
    [created release];
}
@end

