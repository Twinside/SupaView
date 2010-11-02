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

typedef void (^FileDropResponder)( NSURL* fileUrl );
typedef void (^Notifier)();

typedef enum DropStatus_t
{
    NoDrop,
    AcceptDrop,
    RefuseDrop
} DropStatus;

typedef enum AnimationEnd_t
{
    AnimationNarrow,
    AnimationPopNarrow,
    AnimationZoom
} AnimationEnd;

@interface SVTreeMapView : NSView <NSAnimationDelegate> {
    IBOutlet NSScroller   *horizontalScroller;
    IBOutlet NSScroller   *verticalScroller;

    NSRect                virtualSize;
    SVLayoutNode          *viewedTree;
    SVGeometryGatherer    *geometry;
    SVColorWheel          *wheel;

    BOOL                  lockAnyMouseEvent;
    AnimationEnd          animationKind;
    NSAnimation           *zoomAnim;
    NSMutableArray        *narrowingStack;
    
    SVFileTree            *currentSelection;
    SVLayoutLeaf          *selectedLayoutNode;

    DropStatus            currentDropStatus;
    
    NSRect                currentRect;
    NSURL                 *currentURL;
    NSURL                 *selectedURL;
    BOOL                  isSelectionFile;

    BOOL                  dragged;
    
    FileDropResponder     dragResponder;
    Notifier              stateChangeNotifier;

    IBOutlet SVMainWindowController *parentControler;
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

- (void)setFileDropResponder:(FileDropResponder)r;
- (void)setStateChangeResponder:(Notifier)r;

- (void)narrowSelected;
- (void)popNarrowing;
- (void)revealSelectionInFinder;
- (void)deleteSelection:(BOOL)putInTrash;
- (void)refreshLayoutTree:(SVLayoutNode*)tree
          withUpdatedPath:(NSURL*)updatedPath;

- (IBAction)selectSubItem:(id)sender;

- (BOOL)isAtTopLevel;
- (BOOL)isSelectionReavealableInFinder;
- (BOOL)isSelectionNarrowable;
- (BOOL)isZoomMaximum;
- (BOOL)isZoomMinimum;

@end
