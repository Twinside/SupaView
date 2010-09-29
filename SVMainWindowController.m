//
//  SVMainWindowController.m
//  SupaView
//
//  Created by Vincent Berthoux on 20/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVMainWindowController.h"
#import "SVSupaViewAppDelegate.h"
#import "SVGlobalQueues.h"

@interface SVMainWindowController (Private)
- (void)commitTree;
- (void)updateView;
- (void)openURL:(NSURL*)url;
@end

@implementation SVMainWindowController
@synthesize window;

@synthesize atMaximumZoom;
@synthesize atMinimumZoom;
@synthesize showableInFinder;
@synthesize narrowable;
@synthesize atTopLevel;

- (IBAction)zoomInView:sender { [mainTreeView zoomBy:-0.1f]; }
- (IBAction)zoomOutView:sender { [mainTreeView zoomBy:0.1f]; }
- (id)init
{
    self = [super init];
    curentlyNavigated = nil;
    scannedUrl = nil;

    atMaximumZoom = [NSNumber numberWithBool:FALSE];
    atMinimumZoom = [NSNumber numberWithBool:FALSE];
    showableInFinder = [NSNumber numberWithBool:FALSE];
    narrowable = [NSNumber numberWithBool:FALSE];
    atTopLevel = [NSNumber numberWithBool:TRUE];

    return self;
}

- (void)mapStateChange
{
    self.atMaximumZoom = [NSNumber numberWithBool:[mainTreeView isZoomMaximum]];
    self.atMinimumZoom = [NSNumber numberWithBool:[mainTreeView isZoomMinimum]];
    self.narrowable = [NSNumber numberWithBool:[mainTreeView isSelectionNarrowable]];
    self.atTopLevel = [NSNumber numberWithBool:[mainTreeView isAtTopLevel]];
    self.showableInFinder = [NSNumber numberWithBool:[mainTreeView isSelectionReavealableInFinder]];
}

- (void)awakeFromNib
{
    [mainTreeView setFileDropResponder:^(NSURL* url){[self openURL:url];} ];
    [mainTreeView setStateChangeResponder:^(void){ [self mapStateChange];} ];
    NSURL   *toOpen = [[SVGlobalQueues sharedQueues] getFileFromQueue];

    if ( toOpen != nil )
        [self openURL:toOpen];
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

- (IBAction)narrowFolder:(id)sender
{
    [mainTreeView narrowSelected];
}

- (IBAction)goUp:(id)sender
{
    [mainTreeView popNarrowing];
}

- (IBAction)revealInFinder:(id)sender
{
    [mainTreeView revealSelectionInFinder];
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
    SVLayoutNode  *created =
        [curentlyNavigated createLayoutTree];

    [mainTreeView setTreeMap:created
                       atUrl:scannedUrl];
    [created release];
    [scanProgress stopAnimation:self];
}

- (void)updateView
{
    SVLayoutNode  *created =
        [curentlyNavigated createLayoutTree];

    [mainTreeView setTreeMap:created
                       atUrl:scannedUrl];
    [created release];
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
    return [toolbarItem isEnabled];
}

@end
