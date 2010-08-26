//
//  SupaViewAppDelegate.m
//  SupaView
//
//  Created by Vincent Berthoux on 12/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVSupaViewAppDelegate.h"

@implementation SupaViewAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
    curentlyNavigated = nil;
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
    {
        curentlyNavigated =
            [FileTree createFromPath:[oPanel URL]];
        
        [mainTreeView setTreeMap:[curentlyNavigated createLayoutTree]];
    }
}

@end
