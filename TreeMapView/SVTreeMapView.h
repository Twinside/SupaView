//
//  TreeMapView.h
//  SupaView
//
//  Created by Vincent Berthoux on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SVLayoutNode.h"
#import "SVGeometryGatherer.h"

typedef void (^FileDropResponder)( NSURL* fileUrl );
typedef void (^Notifier)();

typedef enum DropStatus_t
{
    NoDrop,
    AcceptDrop,
    RefuseDrop
} DropStatus;

@interface SVTreeMapView : NSView <NSAnimationDelegate> {
    NSRect                virtualSize;
    SVLayoutNode          *viewedTree;
    SVGeometryGatherer    *geometry;
    SVColorWheel          *wheel;

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
}

- (id)initWithFrame:(NSRect)frameRect;
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

- (BOOL)isAtTopLevel;
- (BOOL)isSelectionReavealableInFinder;
- (BOOL)isSelectionNarrowable;
- (BOOL)isZoomMaximum;
- (BOOL)isZoomMinimum;

@end
