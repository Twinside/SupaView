//
//  TreeMapView.m
//  SupaView
//
//  Created by Vincent Berthoux on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVTreeMapView.h"
#import "SVColorWheel.h"
#import "SVUtils.h"

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
    NSRect frame = [self frame];
    [geometry startGathering:&frame
                    inBounds:&virtualSize];
    NSRect  viewFrame = [self frame];
    
    SVDrawInfo info =
        { .limit = &virtualSize
        , .gatherer = geometry
        , .minimumWidth = [geometry virtualPixelWidthSize]
        , .minimumHeight = [geometry virtualPixelHeightSize]
        , .wheel = wheel
        };

    [viewedTree drawGeometry:info
                    inBounds:&viewFrame];

    [geometry stopGathering];
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
    
    size_t      rectCount = [geometry rectangleCount];

    NSRectArray rectArray = [geometry getRectangles];
    NSColor     **colorArray = [geometry getColors];
    NSRectFillListWithColors ( rectArray, colorArray, rectCount );

    [[NSColor whiteColor] setFill];
    for ( size_t i = 0; i < rectCount; i++ )
        NSFrameRectWithWidth( rectArray[ i ], 1.0 );
    
    [[NSColor blackColor] setFill];
    for ( SVStringDraw *str in [geometry getText] )
    {
        [[str text] drawInRect:*[str position]
                withAttributes:nil];
    }
    NSFrameRectWithWidth( virtualSize, 2.0 );
}

- (void) translateBy:(CGFloat)dx  andBy:(CGFloat)dy
{
    NSRect frame = [self frame];

    CGFloat nx = maxi( virtualSize.origin.x + dx, 0.0 );
    CGFloat ny = maxi( virtualSize.origin.y + dy, 0.0 );

    CGFloat right = nx + virtualSize.size.width;
    CGFloat top = ny + virtualSize.size.height;
    
    CGFloat frameRight = frame.origin.x + frame.size.width;
    CGFloat frameTop = frame.origin.y + frame.size.height;
    
    virtualSize.origin.x = nx + mini( 0.0, frameRight - right );
    virtualSize.origin.y = ny + mini( 0.0, frameTop - top );
}

- (void)stretchBy:(CGFloat)x andBy:(CGFloat)y
{
    NSRect frame = [self frame];

    CGFloat deltaWidth = virtualSize.size.width * x;
    CGFloat deltaHeight = virtualSize.size.height * y;

    CGFloat nWidth = virtualSize.size.width + deltaWidth;
    CGFloat nHeight = virtualSize.size.height + deltaHeight;

    virtualSize.origin.x =
        maxi( virtualSize.origin.x - deltaWidth / 2.0, 0.0f );
    virtualSize.origin.y =
        maxi( virtualSize.origin.y - deltaHeight / 2.0, 0.0f );

    CGFloat right = virtualSize.origin.x + virtualSize.size.width;
    CGFloat top = virtualSize.origin.y + virtualSize.size.height;
    
    CGFloat frameRight = frame.origin.x + frame.size.width;
    CGFloat frameTop = frame.origin.y + frame.size.height;

    virtualSize.size.width = nWidth + mini( 0.0, frameRight - right );
    virtualSize.size.height = nHeight + mini( 0.0, frameTop - top );
}

- (void) setFrameSize:(NSSize)newSize

{
    NSRect oldFrame = [self frame];
    
    [super setFrameSize:newSize];
    
    [self stretchBy:newSize.width / oldFrame.size.width - 1.0f
              andBy:newSize.height / oldFrame.size.height - 1.0f];

    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (void)scrollWheel:(NSEvent*)event
{
    [self translateBy:-[event deltaX] 
                andBy:[event deltaY]];
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (void)magnifyWithEvent:(NSEvent *)event
{
    [self stretchBy:[event magnification]
              andBy:[event magnification]];
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

@end

