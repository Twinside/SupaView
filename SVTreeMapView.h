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

@interface SVTreeMapView : NSView {
    NSRect                virtualSize;
    SVLayoutTree          *viewedTree;
    SVGeometryGatherer    *geometry;
    SVColorWheel          *wheel;

    NSFont                *drawingFont;
    NSDictionary          *stringAttributs;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;
- (void)drawRect:(NSRect)dirtyRect;

- (void)zoomBy:(CGFloat)amount;

- (void)magnifyWithEvent:(NSEvent*)event;
- (void)scrollWheel:(NSEvent*)event;

- (void) updateGeometrySize;
- (void)setTreeMap:(SVLayoutTree*)tree;
@end
