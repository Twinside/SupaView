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

@interface TreeMapView : NSView {
    LayoutTree          *viewedTree;
    GeometryGatherer    *geometry;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)drawRect:(NSRect)dirtyRect;

- (void)setTreeMap:(LayoutTree*)tree;
@end
