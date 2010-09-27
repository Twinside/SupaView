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

@interface SVTreeMapView : NSView {
    NSRect                virtualSize;
    SVLayoutNode          *viewedTree;
    SVGeometryGatherer    *geometry;
    SVColorWheel          *wheel;

    NSMutableArray        *narrowingStack;
    
    SVFileTree            *currentSelection;
    SVLayoutLeaf          *selectedLayoutNode;
    
    NSURL                 *currentURL;
    NSURL                 *selectedURL;
    BOOL                  isSelectionFile;

    NSFont                *drawingFont;
    NSDictionary          *stringAttributs;
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

- (void)updateGeometrySize;
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
