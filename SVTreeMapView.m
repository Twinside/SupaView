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
#import "LayoutTree/SVLayoutLeaf.h"

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

    narrowingStack = [[NSMutableArray alloc] initWithCapacity:10];
    
    [drawingFont retain];
    [stringAttributs retain];
    [self updateGeometrySize];
    currentURL = nil;
    selectedURL = nil;
    currentSelection = nil;
    selectedLayoutNode = nil;
    isSelectionFile = FALSE;
    dragResponder = nil;

    [self registerForDraggedTypes:
                [NSArray arrayWithObjects: NSURLPboardType
                                         , nil]];
    return self;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {    
    NSPasteboard *pboard;    
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSURLPboardType] )
        return NSDragOperationGeneric;
    
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSURLPboardType] )
    {
        NSArray *files = [pboard propertyListForType:NSURLPboardType];
        NSString *newRoot = [files objectAtIndex:0];

        if ( newRoot != nil && dragResponder != nil )
            dragResponder( [NSURL URLWithString:newRoot] );
    }
    
    return YES;
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
    [narrowingStack release];
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

- (void)setTreeMap:(SVLayoutNode*)tree
             atUrl:(NSURL*)url
{
    [viewedTree release];
    [selectedURL release];
    [currentURL release];
    [narrowingStack removeAllObjects];

    viewedTree = tree;
    currentURL = url;
    selectedURL = nil;
    currentSelection = nil;
    selectedLayoutNode = nil;
    
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
    if (viewedTree == nil || geometry == nil)
    {
        [super drawRect:dirtyRect];
        NSFont *msgFont =
            [NSFont fontWithName:@"Helvetica" 
                            size:20];
        NSDictionary *strDrawAttr = 
            [NSDictionary dictionaryWithObject:msgFont
                                        forKey:NSFontAttributeName];

        CGFloat boxSize = 50.0f;
        CGFloat strokeSize = 5.0f;
        CGFloat boxMargin = 20.0f;

        NSRect bounds = [self bounds];
        NSRect rectWhere =
            { .origin = { .x = bounds.origin.x
                             + (bounds.size.width - boxSize - boxMargin) / 2
                        , .y = bounds.origin.y
                             + (bounds.size.height - boxSize - boxMargin) / 2 }
            , .size = { .width = boxSize + boxMargin
                      , .height = boxSize + boxMargin } };

        NSBezierPath *roundRect = 
            [NSBezierPath bezierPathWithRoundedRect:rectWhere
                                            xRadius:10.0f
                                            yRadius:10.0f];

        CGFloat lineDash[] = { 7.0f, 5.0f };
        
        [roundRect setLineWidth:strokeSize];
        [roundRect setLineDash:lineDash
                         count:sizeof(lineDash) / sizeof(CGFloat)
                         phase:0.0];
        [roundRect stroke];

        CGFloat textBoxWidth = 240;
        CGFloat textBoxHeight = 25;
        NSRect where = { .origin = { .x = bounds.origin.x
                                        + (bounds.size.width - textBoxWidth) / 2
                                   , .y = rectWhere.origin.y
                                        - boxSize / 2
                                        - textBoxHeight }
                       , .size = { .width = textBoxWidth
                                 , .height = textBoxHeight} };

        [@"Drag volume or folder here"
                    drawInRect:where
                withAttributes:strDrawAttr];

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
    SVLayoutLeaf *foundNode =
            [viewedTree getSelected:p
                           withInfo:&info
                          andBounds:&frame];
    
    SVFileTree  *found = [foundNode fileNode];
    
    if ( found != currentSelection )
    {
        currentSelection = found;
        selectedLayoutNode = foundNode;
        
        [selectedURL release];
        selectedURL = info.selectedName;
        isSelectionFile = info.selectedIsFile;
        [self updateGeometry];
        [self setNeedsDisplay:YES];
        [[self window] setRepresentedURL:selectedURL];
    }
    
    if ( [theEvent clickCount] >= 2 )
        [self narrowSelected];
}

- (void)revealSelectionInFinder
{
    if ( selectedURL == nil )
        return;
    
    if ( isSelectionFile )
        [[NSWorkspace sharedWorkspace]
                    openFile:[[selectedURL URLByDeletingLastPathComponent] path]
             withApplication:@"Finder"];
    else
        [[NSWorkspace sharedWorkspace]
                    openFile:[selectedURL path]
             withApplication:@"Finder"];
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

- (void)setFileDropResponder:(FileDropResponder)r
{
    dragResponder = Block_copy(r);
}

- (void)narrowSelected
{
    if ( isSelectionFile )
        return;
    
    [narrowingStack addObject:viewedTree];
    viewedTree = selectedLayoutNode;
    
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (void)popNarrowing
{
    if ( [narrowingStack count] == 0 )
        return;
    
    viewedTree = [narrowingStack lastObject];
    [narrowingStack removeLastObject];
    
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}
@end

