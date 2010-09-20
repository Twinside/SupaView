//
//  SVMainWindowController.m
//  SupaView
//
//  Created by Vincent Berthoux on 20/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVMainWindowController.h"

@interface SVMainWindowController (Private)
- (void)commitTree;
- (void)updateView;
- (void)openURL:(NSURL*)url;
@end

@implementation SVMainWindowController
@synthesize window;

- (IBAction)zoomInView:sender { [mainTreeView zoomBy:-0.1f]; }
- (IBAction)zoomOutView:sender { [mainTreeView zoomBy:0.1f]; }
- (id)init
{
    self = [super init];
    curentlyNavigated = nil;
    scannedUrl = nil;
    
    return self;
}

- (void)awakeFromNib
{
    [mainTreeView setFileDropResponder:^(NSURL* url){[self openURL:url];} ];
}

- (IBAction)openDocument: sender
{
    int result;
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
 
    [oPanel setAllowsMultipleSelection:(BOOL)NO];
    [oPanel setCanChooseFiles:NO];
    [oPanel setCanChooseDirectories:YES];

    result = [oPanel runModal];

    if (result == NSFileHandlingPanelOKButton)
        [self openURL:[oPanel URL]];
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

@implementation SVMainWindowController (Private)
- (void)openURL:(NSURL*)url
{
    scannedElementCount = 0;

    [curentlyNavigated release];
    curentlyNavigated = nil;
    [scannedUrl release];
    scannedUrl = nil;
    
    [scanProgress setIndeterminate:TRUE];
    [scanProgress startAnimation:self];
    scannedUrl = url;
    [scannedUrl retain];

    // start parrallel crawling asynchronously
    curentlyNavigated =
        [SVFileTree createFromPath:scannedUrl
                    updateReceiver:self
                        endNotifier:^{[self commitTree];}];
}

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
