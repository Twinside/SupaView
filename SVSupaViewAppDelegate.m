//
//  SupaViewAppDelegate.m
//  SupaView
//
//  Created by Vincent Berthoux on 12/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVSupaViewAppDelegate.h"

@implementation SupaViewAppDelegate

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag
{
    return !flag;
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
    [NSBundle loadNibNamed:@"MainMenu" owner:self];
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

@end

