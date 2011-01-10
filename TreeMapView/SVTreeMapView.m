//
//  TreeMapView.m
//  SupaView
//
//  Created by Vincent Berthoux on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVTreeMapView.h"
#import "../SVColorWheel.h"
#import "../SVUtils.h"
#import "../SVSizes.h"
#import "SVNarrowingState.h"
#import "../LayoutTree/SVLayoutLeaf.h"
#import "../LayoutTree/Layout.searching.h"
#import "../SVMainWindowController.h"
#import "SVTreeMapView.private.h"
#import "SVTreeMapView.scroller.h"
#import "AnimationPerFrame.h"

@implementation SVTreeMapView
- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];

    if (!self) return self;

    wheel = [[SVColorWheel alloc] init];
    virtualSize = frameRect;
    narrowingStack = [[NSMutableArray alloc] initWithCapacity:10];
    
    [self updateGeometrySize];
    currentURL = nil;
    selectedURL = nil;
    currentSelection = nil;
    selectedLayoutNode = nil;
    isSelectionFile = FALSE;
    viewedTree = nil;
    lockAnyMouseEvent = FALSE;

    return self;
}

- (void)awakeFromNib
{
    [self allocateInitScroller];
    [pathView setDoubleAction:@selector(pathDoubleClick)];
}

- (void)dealloc
{
    // the next three lines are "FUCKING UGLY"
    // but it's the only way I've found to release
    // the MainWindowController of the nib file.
    // As it keep a reference to a filetree, it's
    // really important to free it.
    [parentControler release];
    // for the window
    [parentControler release];
    // ???
    [parentControler release];


    [viewedTree release];
    [geometry release];
    [wheel release];
    [selectedURL release];
    [currentURL release];
    [narrowingStack release];
    [currentSelection release];
    [selectedLayoutNode release];
    [super dealloc];
}

- (void)setTreeMap:(SVLayoutNode*)tree
             atUrl:(NSURL*)url
{
    [selectedURL release];
    selectedURL = nil;

    [currentSelection release];
    currentSelection = nil;

    [selectedLayoutNode release];
    selectedLayoutNode = nil;

    [viewedTree release];
    viewedTree = tree;
    [viewedTree retain];

    [currentURL release];
    currentURL = url;
    [currentURL retain];

    [narrowingStack removeAllObjects];
    
    if ( tree == nil )
        return;
    
    [self updateGeometry];
    [self setNeedsDisplay:YES];
    stateChangeNotifier();
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
    NSDictionary *attr = [geometry drawStringAttributes];
    for ( SVStringDraw *str in [geometry getText] )
    {
        [[str text] drawInRect:*[str position]
                withAttributes:attr];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawBackRect];
    
    if (viewedTree == nil || geometry == nil)
        return;
    
    [self drawFrameRect];
    [self drawText];
    
    // NSFrameRectWithWidth( virtualSize, 2.0 );
    // [self drawDropStatus:dirtyRect];
}

- (void) translateBy:(CGFloat)dx  andBy:(CGFloat)dy
{
    NSRect frame = [self bounds];

    CGFloat nx = maxi( virtualSize.origin.x + dx, 0.0 );
    CGFloat ny = maxi( virtualSize.origin.y + dy, 0.0 );

    CGFloat right = nx + virtualSize.size.width;
    CGFloat top = ny + virtualSize.size.height;
    
    CGFloat frameRight = frame.origin.x + frame.size.width;
    CGFloat frameTop = frame.origin.y + frame.size.height;
    
    virtualSize.origin.x = nx + mini( 0.0, frameRight - right );
    virtualSize.origin.y = ny + mini( 0.0, frameTop - top );
    [self updateScrollerPosition];
}

- (void)stretchBy:(CGFloat)x andBy:(CGFloat)y
{
    NSRect frame = [self bounds];

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
    [self updateScrollerPosition];
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

- (void)selectAtPoint:(NSPoint)p
{
    NSRect frame = [self bounds];

    SVDrawInfo info =
        { .limit = &virtualSize
        , .gatherer = nil
        , .minimumWidth = [geometry virtualPixelWidthSize]
        , .minimumHeight = [geometry virtualPixelHeightSize]
        , .wheel = nil
        , .selection = { .name = currentURL
                       , .node = nil
                       , .isFile = FALSE
                       , .layoutNode = nil
                       }
        , .depth = 0
        };
    

    [info.selection.name retain];
    SVLayoutLeaf *foundNode =
            [viewedTree getNodeAtPoint:p
                              withInfo:&info
                             andBounds:&frame];
    
    SVFileTree  *found = [foundNode fileNode];
    
    if ( found != currentSelection )
    {
        [currentSelection release];
        currentSelection = found;
        [currentSelection retain];
        
        [selectedLayoutNode release];
        selectedLayoutNode = foundNode;
        [selectedLayoutNode retain];
        
        [selectedURL release];
        selectedURL = info.selection.name;
        isSelectionFile = info.selection.isFile;
        currentRect = info.selection.rect;
        [self updateGeometry];
        [self setNeedsDisplay:YES];

        NSWindow *window = [self window];

        [window setRepresentedURL:selectedURL];
        [window setTitle:[selectedURL lastPathComponent]];
        [pathView setURL:selectedURL];
        
        stateChangeNotifier();
    }
}

- (BOOL)becomeFirstResponder {return YES; }
- (BOOL)resignFirstResponder {return YES; }
- (BOOL)acceptsFirstResponder { return YES; }
- (BOOL)needsPanelToBecomeKey  { return YES; }
- (BOOL)isOpaque { return YES; }
- (BOOL)wantsDefaultClipping { return NO; }

- (IBAction)selectSubItem:(id)sender
{
    NSPoint pickPoint = { currentRect.origin.x + blockSizes.leftMargin 
                            + [geometry virtualPixelWidthSize]
                        , currentRect.origin.y + currentRect.size.height
                            - blockSizes.bottomMargin
                            - blockSizes.textHeight
                            - [geometry virtualPixelHeightSize]
                        };
    [self selectAtPoint:pickPoint];
}

- (void)keyDown:(NSEvent *)theEvent
{
    // arrow keys have this mask
    if (! ([theEvent modifierFlags] & NSNumericPadKeyMask))
    {
        [super keyDown:theEvent];
        return;
    }

    NSString *theArrow = [theEvent charactersIgnoringModifiers];

    if ( [theArrow length] == 0 )
        return;            // reject dead keys

    NSPoint pickPoint;

    switch ( [theArrow characterAtIndex:0] )
    {
    case NSLeftArrowFunctionKey:
        pickPoint.x = currentRect.origin.x - [geometry virtualPixelWidthSize];
        pickPoint.y = currentRect.origin.y + currentRect.size.height / 2;
        break;

    case NSRightArrowFunctionKey:
        pickPoint.x = currentRect.origin.x + currentRect.size.width
                    + [geometry virtualPixelWidthSize];
        pickPoint.y = currentRect.origin.y + currentRect.size.height / 2;
        break;

    case NSUpArrowFunctionKey:
        pickPoint.x = currentRect.origin.x + currentRect.size.width / 2;
        pickPoint.y = currentRect.origin.y + currentRect.size.height
                    + [geometry virtualPixelHeightSize];
        break;

    case NSDownArrowFunctionKey:
        pickPoint.x = currentRect.origin.x + currentRect.size.width / 2;
        pickPoint.y = currentRect.origin.y - 1
                    - [geometry virtualPixelHeightSize];
        break;

    default:
        [super keyDown:theEvent];
        return;
    }

    [self selectAtPoint:pickPoint];
}

- (void)mouseDown:(NSEvent*)theEvent { dragged = FALSE; }

- (void)mouseDragged:(NSEvent*)theEvent
{
    if ( lockAnyMouseEvent ) return;

    dragged = TRUE;
    [[NSCursor closedHandCursor] push];
    
    [self translateBy:-[theEvent deltaX]
                andBy:[theEvent deltaY]];
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent*)theEvent
{
    if ( lockAnyMouseEvent ) return;

    if ( dragged )
    {
        [NSCursor pop];
        [[NSCursor arrowCursor] push];
        return;
    }
    
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    [geometry unscalePoint:&p];

    [self selectAtPoint:p];

    if ( [theEvent clickCount] >= 2 )
    {
        if ( isSelectionFile )
            [self revealSelectionInFinder];
        else
            [self narrowSelected];
    }
}

- (void)revealSelectionInFinder
{
    if ( lockAnyMouseEvent ) return;
    if ( selectedURL == nil )
        return;
    
    NSString *parentFolder =
        [[selectedURL URLByDeletingLastPathComponent] path];

    [[NSWorkspace sharedWorkspace] selectFile:[selectedURL path]
                     inFileViewerRootedAtPath:parentFolder];
}

- (void)scrollWheel:(NSEvent*)event
{
    if ( lockAnyMouseEvent ) return;
    NSUInteger modFlags = [NSEvent modifierFlags];

    if ( modFlags & NSAlternateKeyMask )
    {
        [self stretchBy:[event deltaY] * (-0.02f)
                  andBy:[event deltaY] * (-0.02f)];
    }
    else
    {
        [self translateBy:-[event deltaX] 
                    andBy:[event deltaY]];
    }

    [self updateGeometry];
    [self setNeedsDisplay:YES];
    stateChangeNotifier();
}

- (void)zoomBy:(CGFloat)amount
{
    if ( lockAnyMouseEvent ) return;
    NSRect prevRect = virtualSize;

    [self stretchBy:amount andBy:amount];
    zoomAnim =
        [[AnimationPerFrame alloc] initWithView:self
                                       fromRect:prevRect
                                         toRect:virtualSize
                                    andDuration:0.10f];
    animationKind = AnimationZoom;
    virtualSize = prevRect;
    [zoomAnim startAnimation];
    stateChangeNotifier();
}

- (void)magnifyWithEvent:(NSEvent *)event
{
    if ( lockAnyMouseEvent ) return;
    [self stretchBy:-[event magnification]
              andBy:-[event magnification]];
    [self updateGeometry];
    [self setNeedsDisplay:YES];
    stateChangeNotifier();
}

- (void)setStateChangeResponder:(Notifier)r
{
    stateChangeNotifier = Block_copy(r);
    stateChangeNotifier();
}

- (void)narrowSelected
{
    if ( lockAnyMouseEvent ) return;
    if ( isSelectionFile )
        return;
    
    virtualSize = [self bounds];
    
    SVNarrowingState *narrow = 
        [[SVNarrowingState alloc] initWithNode:viewedTree
                                        andURL:currentURL
                                        inRect:&currentRect];
    [narrowingStack addObject:narrow];
    [narrow release];
    
    zoomAnim =
        [[AnimationPerFrame alloc] initWithView:self
                                       fromRect:[self bounds]
                                         toRect:currentRect
                                    andDuration:0.25f];

    animationKind = AnimationNarrow;
    [zoomAnim startAnimation];
    [self updateScrollerPosition];
    stateChangeNotifier();
}

- (void)refreshLayoutTree:(SVLayoutNode*)tree
          withUpdatedPath:(NSURL*)updatedPath
{
    size_t i = 0;

    // if refresh is in narrowingStack
        // then pop it
    for (SVNarrowingState *narrow in narrowingStack)
    {
        if ( [updatedPath isEqual:[narrow url]] )
        {
            size_t toPop = [narrowingStack count] - i - 1;
            [narrowingStack
                removeObjectsInRange:NSMakeRange(i, toPop)];
        }
        i++;
    }

    // for every narrowing, resync it using the new tree :
        // search URL and update rect
}

- (void)popNarrowing
{
    if ( lockAnyMouseEvent ) return;
    if ( [narrowingStack count] == 0 )
        return;
    
    virtualSize = [self bounds];
    
    SVNarrowingState *st = [narrowingStack lastObject];
    [viewedTree release];
    viewedTree = [st node];
    [viewedTree retain];

    zoomAnim =
        [[AnimationPerFrame alloc] initWithView:self
                                       fromRect:[st rect]
                                         toRect:[self bounds]
                                    andDuration:0.25f];

    animationKind = AnimationPopNarrow;
    virtualSize = [st rect];
    [currentURL release];
    currentURL = [st url];
    [currentURL retain];

    [narrowingStack removeLastObject];
    [self updateScrollerPosition];

    stateChangeNotifier();
    [self updateGeometry];
    [self setNeedsDisplay:YES];
    [zoomAnim startAnimation];
}

- (BOOL)isZoomMinimum { return viewedTree == nil; }
- (BOOL)isZoomMaximum { return viewedTree == nil; }

- (BOOL)isSelectionNarrowable
{
    return viewedTree != nil && selectedURL != nil && !isSelectionFile;
}

- (BOOL)isAtTopLevel
{
    return viewedTree == nil || [narrowingStack count] == 0;
}

- (BOOL)isSelectionReavealableInFinder
{
    return viewedTree != nil && selectedURL != nil;
}

- (void)deleteSelection:(BOOL)putInTrash
{
    NSURL *masterURL;
    SVLayoutNode *masterLayout;

    // we must update the tree from the upper
    // most root of the layout tree. So we
    // must pick it from the narrowing stack
    // if any.
    if ( [narrowingStack count] > 0 )
    {
        SVNarrowingState *st =
            [narrowingStack objectAtIndex:0];

        masterURL = [st url];
        masterLayout = [st node];
    }
    else
    {
        masterURL = currentURL;
        masterLayout = viewedTree;
    }

    NSArray *rootComp = [masterURL pathComponents];
    NSArray *selRoot = [selectedURL pathComponents];
    int deleteIndex = [rootComp count] - 1;

    [selRoot retain];

    FileDeleteRez rez = 
        [[masterLayout fileNode]
            deleteNodeWithURLParts:selRoot
                        atIndex:deleteIndex];

    [SVLayoutNode deleteNode:masterLayout
                       atUrl:selRoot
                      atPart:deleteIndex];

    [rez.deleted release];
    [selRoot release];
    
    [selectedURL release];
    selectedURL = nil;
    [currentSelection release];
    currentSelection = nil;

    if ( selectedLayoutNode == viewedTree )
    {
        if ( [narrowingStack count] > 0 )
            [self popNarrowing];
        else
        {
            viewedTree = nil;
            [parentControler notifyViewCleanup];
            [[self window] setRepresentedURL:nil];
        }
    }

    [selectedLayoutNode release];
    selectedLayoutNode = nil;

    NSWindow *window = [self window];
    [window setRepresentedURL:nil];
    [window setTitle:@"SupaView"];
    
    [self updateGeometry];
    [self setNeedsDisplay:YES];

    stateChangeNotifier();
}

- (IBAction)pathSelection:(id)sender
{
    /* only get the event to be selected, the
     * pathDoubleClick really handle the stuff */
}

- (IBAction)pathDoubleClick
{
    NSURL *clickedUrl =
        [[pathView clickedPathComponentCell] URL];
    NSString *clickedPath = [clickedUrl path];

    // if the user double clicked on the current
    // 'top' URL, we don't care, just leave.
    if ( [clickedUrl isEqual:currentURL] )
        return;

    int narrowingCount = [narrowingStack length];
    NSString *rootPath;

    // we are checking if the clicked url is beyound
    // the scanned root.
    if ( narrowingCount > 0)
        rootPath = [[[narrowingStack objectAtIndex:0] url] path];
    else
        rootPath = currentURL;

    // we are before the rootpath..
    if ( [rootPath hasPrefix:clickedPath] )
        return; // do nothing.

    // we got element in the narrowing,
    // dump everything but the last
    if ( narrowingCount == 0 )
    {
    }
    else // otherwise, just push the root state, and
    {    // move into.
        
    }
}
@end

