//
//  SupaViewAppDelegate.m
//  SupaView
//
//  Created by Vincent Berthoux on 12/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SupaViewAppDelegate.h"

@implementation SupaViewAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

- (IBAction)openDocument: sender
{
    NSLog(@"Meh");
    if ( mainTreeView != nil )
        NSLog( @"mainTreeView not null !!" );
}

@end
