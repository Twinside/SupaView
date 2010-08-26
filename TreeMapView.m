//
//  TreeMapView.m
//  SupaView
//
//  Created by Vincent Berthoux on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TreeMapView.h"


@implementation TreeMapView
- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    return self;
}

- (void)setTreeMap:(LayoutTree*)tree
{
    [viewedTree release];
    [geometry release];
    
    viewedTree = tree;
    geometry = nil;
    
    [viewedTree retain];
    
    if ( tree == nil )
        return;
    
    int rectangleCount =
        [tree countRectNeed];
    
    geometry =
        [[GeometryGatherer alloc] initWithRectCount:rectangleCount];
    
    NSRect  viewBounds = [self bounds];
    [viewedTree drawGeometry:geometry inBounds:&viewBounds];
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (geometry == nil)
    {
        [super drawRect:dirtyRect];
        return;
    }
    
    NSRectArray rectArray = [geometry getRectangles];
    NSColor     **colorArray = [geometry getColors];
    NSRectFillListWithColors ( rectArray, colorArray, [geometry rectangleCount] );
}
@end
