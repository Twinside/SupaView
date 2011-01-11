//
//  TreeMapView.h
//  SupaView
//
//  Created by Vincent Berthoux on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "../LayoutTree/SVLayoutNode.h"
#import "../SVGeometryGatherer.h"

@class SVMainWindowController;

typedef void (^Notifier)();

typedef enum AnimationEnd_t
{
    AnimationNarrow,
    AnimationPopNarrow,
    AnimationZoom
} AnimationEnd;

@class SVNodeState;

/**
 * Main GUI class, handle the tree view, draw, manage
 * clicks and animations.
 */
@interface SVTreeMapView : NSView <NSAnimationDelegate> {
    IBOutlet NSScroller   *horizontalScroller;
    IBOutlet NSScroller   *verticalScroller;
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSPathControl *pathView;

    IBOutlet SVMainWindowController *parentControler;

    NSRect                virtualSize;
    SVGeometryGatherer    *geometry;
    SVColorWheel          *wheel;

    BOOL                  lockAnyMouseEvent;
    AnimationEnd          animationKind;
    NSAnimation           *zoomAnim;

    SVNodeState           *root;
    SVNodeState           *current;
    SVNodeState           *selected;

    BOOL                  isSelectionFile;
    BOOL                  dragged;
    
    Notifier              stateChangeNotifier;

}

- (id)initWithFrame:(NSRect)frameRect;
- (void)awakeFromNib;
- (void)dealloc;
- (void)drawRect:(NSRect)dirtyRect;

- (void)zoomBy:(CGFloat)amount;

- (void)magnifyWithEvent:(NSEvent*)event;
- (void)scrollWheel:(NSEvent*)event;

- (void)setTreeMap:(SVLayoutNode*)tree
             atUrl:(NSURL*)url;

- (void)setStateChangeResponder:(Notifier)r;

- (void)narrowSelected;
- (void)popNarrowing;
- (void)revealSelectionInFinder;
- (void)deleteSelection:(BOOL)putInTrash;

- (IBAction)selectSubItem:(id)sender;
- (IBAction)pathSelection:(id)sender;
- (IBAction)pathDoubleClick;

- (BOOL)isAtTopLevel;
- (BOOL)isSelectionReavealableInFinder;
- (BOOL)isSelectionNarrowable;
- (BOOL)isZoomMaximum;
- (BOOL)isZoomMinimum;
@end

