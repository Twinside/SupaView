//
//  TreeMapView.m
//  SupaView
//
//  Created by Vincent Berthoux on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVTreeMapView.h"
#import "SVColorWheel.h"

@implementation SVTreeMapView
- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    wheel = [[SVColorWheel alloc] init];
    return self;
}

- (void)setTreeMap:(SVLayoutTree*)tree
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
        [[SVGeometryGatherer alloc] initWithRectCount:rectangleCount];
    
    NSRect  viewBounds = [self bounds];
    [viewedTree drawGeometry:geometry
                   withColor:wheel
                    inBounds:&viewBounds];
    
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
