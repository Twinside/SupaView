//
//  SupaViewAppDelegate.m
//  SupaView
//
//  Created by Vincent Berthoux on 12/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Sparkle/Sparkle.h>
#import "SVSupaViewAppDelegate.h"
#import "SVGlobalQueues.h"

@implementation SupaViewAppDelegate
@synthesize hasOpenedWindow;

- (id)init
{
    self = [super init];
    hasOpenedWindow = [NSNumber numberWithBool:TRUE];
    return self;
}

- (void)notifyWindowClosed
{
    [self setHasOpenedWindow:[NSNumber numberWithBool:FALSE]];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag
{
    return !flag;
}

- (SUUpdater *)updater {
    return [SUUpdater updaterForBundle:[NSBundle bundleForClass:[self class]]];
}

- (NSString*)versionString
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSDictionary *infoDict = [mainBundle infoDictionary];
 
    NSString *mainString = [infoDict valueForKey:@"CFBundleShortVersionString"];
    NSString *subString = [infoDict valueForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"Version %@ (%@)", mainString, subString];
}

- (IBAction)openAbout:(id)sender
{
    [NSBundle loadNibNamed:@"About" owner:self];
}

- (IBAction)openPreferences:(id)sender
{
    [NSBundle loadNibNamed:@"preferences" owner:self];
}

- (IBAction)donateLinkOpener:(id)sender
{
    NSURL   *donationURL =
        [NSURL URLWithString:@"http://twinside.free.fr/supaview/donate.html"];

    [[NSWorkspace sharedWorkspace] openURL:donationURL];
}


- (IBAction)openDocument:(id)sender
{
    int result;
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
 
    [oPanel setAllowsMultipleSelection:(BOOL)NO];
    [oPanel setCanChooseFiles:NO];
    [oPanel setCanChooseDirectories:YES];

    result = [oPanel runModal];

    if (result == NSFileHandlingPanelOKButton)
        [self application:[NSApplication sharedApplication]
                 openFile:[[oPanel URL] path]];
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

