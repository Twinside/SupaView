//
//  SupaViewAppDelegate.h
//  SupaView
//
//  Created by Vincent Berthoux on 12/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SupaViewAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet id mainTreeView;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)openDocument: sender;

@end
