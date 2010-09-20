//
//  SupaViewAppDelegate.m
//  SupaView
//
//  Created by Vincent Berthoux on 12/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVSupaViewAppDelegate.h"
#import "SVGlobalQueues.h"

@implementation SupaViewAppDelegate

- (id)init
{
    self = [super init];
    return self;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag
{
    return !flag;
}

- (BOOL)application:(NSApplication *)theApplication
           openFile:(NSString *)filename
{
    NSURL* waitingFile = [NSURL fileURLWithPath:filename];
    [[SVGlobalQueues sharedQueues] addFileToQueue:waitingFile];
    
    [NSBundle loadNibNamed:@"MainMenu" owner:self];
    return YES;
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

