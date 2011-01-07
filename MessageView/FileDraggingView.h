//
//  FileDraggingView.h
//  SupaView
//
//  Created by Vincent Berthoux on 07/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void (^FileDropResponder)( NSURL* fileUrl );

typedef enum DropStatus_t
{
    NoDrop,
    AcceptDrop,
    RefuseDrop
} DropStatus;

/**
 * This class implement the behaviour needed to obtain
 * file drag'n'drop in the application. It shouldn't
 * be used as-is but be subclassed.
 */
@interface SVFileDraggingView : NSView {
    FileDropResponder     dragResponder;
    DropStatus            currentDropStatus;
}
- (id)initWithFrame:(NSRect)frameRect;
- (void)setFileDropResponder:(FileDropResponder)r;
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
- (void)draggingEnded:(id<NSDraggingInfo>)sender;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
- (void)drawRect:(NSRect)dirtyRect;
@end
