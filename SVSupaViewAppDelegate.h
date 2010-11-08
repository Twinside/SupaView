//
//  SupaViewAppDelegate.h
//  SupaView
//
//  Created by Vincent Berthoux on 12/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SupaViewAppDelegate : NSObject <NSApplicationDelegate> {
    NSNumber* hasOpenedWindow;
}

- (id)init;
- (void)notifyWindowClosed;

@property (assign) NSNumber* hasOpenedWindow;
- (IBAction)openAbout:(id)sender;
- (IBAction)donateLinkOpener:(id)sender;
- (IBAction)openPreferences:(id)sender;
@end

