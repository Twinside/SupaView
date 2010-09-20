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
#import "SVSizes.h"

@implementation SVTreeMapView
- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    wheel = [[SVColorWheel alloc] init];
    virtualSize = frameRect;
    drawingFont = [NSFont fontWithName:@"Helvetica" size:blockSizes.textHeight];
    stringAttributs = 
        [NSDictionary dictionaryWithObject:drawingFont
                                    forKey:NSFontAttributeName];

    [drawingFont retain];
    [stringAttributs retain];
    [self updateGeometrySize];
    currentURL = nil;
    selectedURL = nil;
    currentSelection = nil;
    isSelectionFile = FALSE;

    return self;
}

- (void)dealloc
{
    [viewedTree release];
    [geometry release];
    [wheel release];
    [drawingFont release];
    [stringAttributs release];
    [selectedURL release];
    [currentURL release];
    [super dealloc];
}

- (void)updateGeometry
{
    NSRect frame = [self frame];
    [geometry startGathering:&frame
                    inBounds:&virtualSize];
    
    SVDrawInfo info =
        { .limit = &virtualSize
        , .gatherer = geometry
        , .minimumWidth = [geometry virtualPixelWidthSize]
        , .minimumHeight = [geometry virtualPixelHeightSize]
        , .wheel = wheel
        , .selected = currentSelection
        , .selectedName = currentURL
        , .depth = 0
        };

    [viewedTree drawGeometry:&info
                    inBounds:&frame];

    [geometry stopGathering];
}

- (void)setTreeMap:(SVLayoutTree*)tree
             atUrl:(NSURL*)url
{
    [viewedTree release];
    [selectedURL release];
    [currentURL release];

    viewedTree = tree;
    currentURL = url;
    selectedURL = nil;
    
    [viewedTree retain];
    [currentURL retain];
    
    if ( tree == nil )
        return;
    
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (void)viewWillStartLiveResize
{
    [super viewWillStartLiveResize];
}

- (void)drawBackRect
{
    size_t      rectCount = [geometry rectangleCount];
    NSRectArray rectArray = [geometry getRectangles];
    NSColor     **colorArray = [geometry getColors];
    NSRectFillListWithColors ( rectArray, colorArray, rectCount );
}

- (void)drawFrameRect
{
    size_t      rectCount = [geometry rectangleCount];
    NSRectArray rectArray = [geometry getRectangles];

    [[NSColor grayColor] setFill];
    for ( size_t i = 0; i < rectCount; i++ )
        NSFrameRectWithWidth( rectArray[ i ], 1.0 );
    
    [[NSColor blackColor] setFill];
}

- (void)drawText
{
    for ( SVStringDraw *str in [geometry getText] )
    {
        [[str text] drawInRect:*[str position]
                withAttributes:stringAttributs];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (geometry == nil)
    {
        [super drawRect:dirtyRect];
        return;
    }
    [self drawBackRect];
    [self drawFrameRect];
    [self drawText];
    
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

    CGFloat midX = virtualSize.origin.x
                 + virtualSize.size.width / 2.0;
    CGFloat midY = virtualSize.origin.y
                 + virtualSize.size.height / 2.0;

    virtualSize.size.width = mini( virtualSize.size.width * (1 + x)
                                 , frame.size.width );
    virtualSize.size.height = mini( virtualSize.size.height * (1 + y)
                                  , frame.size.height );
    CGFloat halfWidth = virtualSize.size.width  / 2.0f;
    CGFloat halfHeight = virtualSize.size.height / 2.0f;

    CGFloat frameRight = frame.origin.x + frame.size.width;
    CGFloat frameTop = frame.origin.y + frame.size.height;

    if ( midX - halfWidth < 0 )
        midX = halfWidth;
    else if ( midX + halfWidth > frameRight )
        midX = frameRight - halfWidth;

    if ( midY - halfHeight < 0 )
        midY = halfHeight;
    else if ( midY + halfHeight > frameTop )
        midY = frameTop - halfHeight;

    virtualSize.origin.x = midX - halfWidth;
    virtualSize.origin.y = midY - halfHeight;
}

- (void) updateGeometrySize
{
    NSRect frame = [self frame];
    [geometry release];

    int maxPerLine = (int)(frame.size.width / blockSizes.minBoxSizeWidth + 1);
    int maxPerColumn = (int)(frame.size.height / blockSizes.minBoxSizeHeight + 1);

    geometry =
        [[SVGeometryGatherer alloc]
                initWithRectCount:maxPerLine * maxPerColumn];
    
}

- (void) setFrameSize:(NSSize)newSize

{
    NSRect oldFrame = [self frame];
    
    [super setFrameSize:newSize];

    [self updateGeometrySize];
    
    [self stretchBy:newSize.width / oldFrame.size.width - 1.0f
              andBy:newSize.height / oldFrame.size.height - 1.0f];

    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent*)theEvent
{
    dragged = FALSE;
}

- (void)mouseDragged:(NSEvent*)theEvent
{
    dragged = TRUE;
    [[NSCursor closedHandCursor] push];
    
    [self translateBy:-[theEvent deltaX]
                andBy:[theEvent deltaY]];
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent*)theEvent
{
    
    if ( dragged )
    {
        [NSCursor pop];
        [[NSCursor arrowCursor] push];
        return;
    }

    NSPoint p = [theEvent locationInWindow];
    p = [self convertPoint:p fromView:nil];
    [geometry unscalePoint:&p];

    NSRect frame = [self frame];

    SVDrawInfo info =
        { .limit = &virtualSize
        , .gatherer = nil
        , .minimumWidth = [geometry virtualPixelWidthSize]
        , .minimumHeight = [geometry virtualPixelHeightSize]
        , .wheel = nil
        , .selected = nil
        , .selectedName = currentURL
        , .depth = 0
        , .selectedIsFile = FALSE
        };
    

    [info.selectedName retain];
    SVFileTree *found =
            [viewedTree getSelected:p
                           withInfo:&info
                          andBounds:&frame];
    
    if ( found != currentSelection )
    {
        currentSelection = found;
        [selectedURL release];
        selectedURL = info.selectedName;
        isSelectionFile = info.selectedIsFile;
        [self updateGeometry];
        [self setNeedsDisplay:YES];
        [[self window] setRepresentedURL:selectedURL];
    }
    
    if ( [theEvent clickCount] >= 2 )
    {
        if ( isSelectionFile )
            [[NSWorkspace sharedWorkspace]
                        openFile:[[selectedURL URLByDeletingLastPathComponent] path]
                withApplication:@"Finder"];
        else
            [[NSWorkspace sharedWorkspace]
                        openFile:[selectedURL path]
                withApplication:@"Finder"];
    }
}

- (void)scrollWheel:(NSEvent*)event
{
    [self translateBy:-[event deltaX] 
                andBy:[event deltaY]];
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (void)zoomBy:(CGFloat)amount
{
    [self stretchBy:amount andBy:amount];
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (void)magnifyWithEvent:(NSEvent *)event
{
    [self stretchBy:-[event magnification]
              andBy:-[event magnification]];
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

@end

