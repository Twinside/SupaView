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
}

@property (assign) IBOutlet NSWindow *window;
- (id)init;
- (IBAction)openDocument:(id)sender;

- (IBAction)zoomInView:(id)sender;
- (IBAction)zoomOutView:(id)sender;

@end
