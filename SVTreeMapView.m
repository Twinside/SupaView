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
    virtualSize = frameRect;
    return self;
}

- (void)updateGeometry
{
    [geometry starGathering];
    NSRect  viewFrame = [self frame];
    
    [viewedTree drawGeometry:geometry
                   withColor:wheel
                    inBounds:&viewFrame
                  withinRect:&virtualSize];
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
    
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (void)viewWillStartLiveResize
{
    [super viewWillStartLiveResize];
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
    
    for ( SVStringDraw *str in [geometry getText] )
    {
        [[str text] drawInRect:*[str position]
                withAttributes:nil];
    }
}

- (void)stretchBy:(CGFloat)x andBy:(CGFloat)y
{
    CGFloat deltaWidth = virtualSize.size.width * x;
    CGFloat deltaHeight = virtualSize.size.height * y;

    virtualSize.origin.x -= deltaWidth / 2.0;
    virtualSize.origin.y -= deltaHeight / 2.0;
    virtualSize.size.width += deltaWidth;
    virtualSize.size.height += deltaHeight;

    [self updateGeometry];
    [self setNeedsDisplay:YES];
    
}

- (void) setFrameSize:(NSSize)newSize

{
    NSRect oldFrame = [self frame];
    
    [self stretchBy:oldFrame.size.width / newSize.width
              andBy:oldFrame.size.height / newSize.height];

    [super setFrameSize:newSize];
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (void)magnifyWithEvent:(NSEvent *)event
{
    [self stretchBy:[event magnification]
              andBy:[event magnification]];
}

@end

