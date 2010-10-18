//
//  SVMainWindowController.h
//  SupaView
//
//  Created by Vincent Berthoux on 20/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SVFileTree.h"
#import "SVTreeMapView.h"

@interface SVMainWindowController : NSObject <SVProgressNotifiable> {
    NSWindow *window;

    SVFileTree *curentlyNavigated;
    NSURL      *scannedUrl;

    IBOutlet NSToolbarItem *zoomIn;
    IBOutlet NSToolbarItem *zoomOut;
    IBOutlet NSView        *scrollView;

    IBOutlet NSProgressIndicator *scanProgress;

    IBOutlet SVTreeMapView *mainTreeView;

    FileSize                scannedElementCount;
    
    
    NSNumber              *atMaximumZoom;
    NSNumber              *atMinimumZoom;
    NSNumber              *showableInFinder;
    NSNumber              *narrowable;
    NSNumber              *atTopLevel;
}

@property (assign) IBOutlet NSWindow *window;
- (id)init;
- (IBAction)openDocument:(id)sender;
- (IBAction)openAbout:(id)sender;
- (IBAction)openPreferences:(id)sender;

- (IBAction)zoomInView:(id)sender;
- (IBAction)zoomOutView:(id)sender;

- (IBAction)narrowFolder:(id)sender;
- (IBAction)goUp:(id)sender;
- (IBAction)revealInFinder:(id)sender;
- (IBAction)donateLinkOpener:(id)sender;
- (IBAction)deleteSelectedElement:(id)sender;


@property (assign) NSNumber* atMaximumZoom;
@property (assign) NSNumber* atMinimumZoom;
@property (assign) NSNumber* showableInFinder;
@property (assign) NSNumber* narrowable;
@property (assign) NSNumber* atTopLevel;
@end
