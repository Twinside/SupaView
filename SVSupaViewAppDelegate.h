//
//  SupaViewAppDelegate.h
//  SupaView
//
//  Created by Vincent Berthoux on 12/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SVFileTree.h"
#import "SVTreeMapView.h"

@interface SupaViewAppDelegate : NSObject <NSApplicationDelegate> {
    SVFileTree *curentlyNavigated;

    NSWindow *window;
    IBOutlet SVTreeMapView *mainTreeView;

    IBOutlet NSToolbarItem *zoomIn;
    IBOutlet NSToolbarItem *zoomOut;
}


- (IBAction)openDocument:(id)sender;

- (IBAction)zoomInView:(id)sender;
- (IBAction)zoomOutView:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
