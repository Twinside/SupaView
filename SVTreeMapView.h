//
//  TreeMapView.h
//  SupaView
//
//  Created by Vincent Berthoux on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SVLayoutTree.h"
#import "SVGeometryGatherer.h"

typedef void (^FileDropResponder)( NSURL* fileUrl );

@interface SVTreeMapView : NSView {
    NSRect                virtualSize;
    SVLayoutTree          *viewedTree;
    SVGeometryGatherer    *geometry;
    SVColorWheel          *wheel;

    SVFileTree            *currentSelection;
    NSURL                 *currentURL;
    NSURL                 *selectedURL;
    BOOL                  isSelectionFile;

    NSFont                *drawingFont;
    NSDictionary          *stringAttributs;
    BOOL                  dragged;
    
    FileDropResponder     dragResponder;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;
- (void)drawRect:(NSRect)dirtyRect;

- (void)zoomBy:(CGFloat)amount;

- (void)magnifyWithEvent:(NSEvent*)event;
- (void)scrollWheel:(NSEvent*)event;

- (void)updateGeometrySize;
- (void)setTreeMap:(SVLayoutTree*)tree
             atUrl:(NSURL*)url;

- (void)setFileDropResponder:(FileDropResponder)r;

@end
