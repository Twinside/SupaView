//
//  FileDraggingView.m
//  SupaView
//
//  Created by Vincent Berthoux on 07/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileDraggingView.h"
#import "../FileTree/SVFileTree.h"

@implementation SVFileDraggingView
- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];

    if (!self)
        return self;

    dragResponder = nil;
    currentDropStatus = NoDrop;

    [self registerForDraggedTypes:
                [NSArray arrayWithObjects: NSURLPboardType
                                         , nil]];
    return self;
}

- (void)setFileDropResponder:(FileDropResponder)r
{
    dragResponder = Block_copy(r);
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {    
    NSPasteboard *pboard;    
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSURLPboardType] )
    {
        NSArray *files = [pboard propertyListForType:NSURLPboardType];
        NSString *newRoot = [files objectAtIndex:0];

        if ( [SVFileTree isAcceptableURL:[NSURL URLWithString:newRoot]] )
            currentDropStatus = AcceptDrop;
        else
            currentDropStatus = RefuseDrop;

        [self setNeedsDisplay:YES];

        return NSDragOperationGeneric;
    }

    currentDropStatus = RefuseDrop;
    [self setNeedsDisplay:YES];

    return NSDragOperationNone;
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender
{
    currentDropStatus = NoDrop;
    [self setNeedsDisplay:YES];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSURLPboardType] )
    {
        NSArray *files = [pboard propertyListForType:NSURLPboardType];
        NSString *newRoot = [files objectAtIndex:0];

        if ( currentDropStatus == AcceptDrop
            && newRoot != nil && dragResponder != nil )
        {
            dragResponder( [NSURL URLWithString:newRoot] );
        }
    }
    
    currentDropStatus = NoDrop;
    [self setNeedsDisplay:YES];

    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    switch ( currentDropStatus )
    {
    case AcceptDrop:
        [[NSColor colorWithDeviceRed:0.8
                               green:1.0
                                blue:0.8
                               alpha:0.5] setFill];
        NSRectFillUsingOperation([self bounds], NSCompositeSourceAtop);
        break;

    case RefuseDrop:
        [[NSColor colorWithDeviceRed:1.0
                               green:0.8
                                blue:0.8
                               alpha:0.5] setFill];
        NSRectFillUsingOperation([self bounds], NSCompositeSourceAtop);
        break;

    case NoDrop: break;
    }
    [[NSColor blackColor] setFill];
}
@end

