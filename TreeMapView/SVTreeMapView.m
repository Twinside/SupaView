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
#import "../LayoutTree/SVLayoutLeaf.h"
#import "../LayoutTree/Layout.searching.h"
#import "../SVMainWindowController.h"
#import "SVTreeMapView.private.h"
#import "SVTreeMapView.scroller.h"
#import "SVNodeState.h"
#import "AnimationPerFrame.h"

typedef SVLayoutLeaf* (^SelectFunction)(SVDrawInfo*,NSRect*);
@implementation SVTreeMapView
- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];

    if (!self) return self;

    wheel = [[SVColorWheel alloc] init];
    
    root = nil;
    current = nil;
    selected = nil;

    isSelectionFile = FALSE;
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

    [root release];
    [current release];
    [selected release];

    [geometry release];
    [wheel release];
    [super dealloc];
}

- (void)setTreeMap:(SVLayoutNode*)tree
             atUrl:(NSURL*)url
{
    [root release];
    root = nil;

    [current release];
    current = nil;

    [selected release];
    selected = nil;

    if ( tree == nil )
        return;

    root =
        [[SVNodeState  alloc] 
            initWithUrl:url
                   file:[tree fileNode]
                 layout:tree
                   size:[self frame]];

    current = root;
    [current retain];
    [pathView setURL:url];
    
    [self updateGeometrySize];
    [self updateScrollerPosition];
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
    
    if (current == nil 
        || current->file == nil 
        || geometry == nil)
        return;
    
    [self drawFrameRect];
    [self drawText];
    // [self drawDropStatus:dirtyRect];
}

- (void) translateBy:(CGFloat)dx  andBy:(CGFloat)dy
{
    NSRect *virtualSize = &current->size;
    NSRect frame = [self bounds];

    CGFloat nx = maxi( virtualSize->origin.x + dx, 0.0 );
    CGFloat ny = maxi( virtualSize->origin.y + dy, 0.0 );

    CGFloat right = nx + virtualSize->size.width;
    CGFloat top = ny + virtualSize->size.height;
    
    CGFloat frameRight = frame.origin.x + frame.size.width;
    CGFloat frameTop = frame.origin.y + frame.size.height;
    
    virtualSize->origin.x = nx + mini( 0.0, frameRight - right );
    virtualSize->origin.y = ny + mini( 0.0, frameTop - top );
    [self updateScrollerPosition];
}

- (void)stretchBy:(CGFloat)x andBy:(CGFloat)y
{
    if ( current == nil )
        return;
    
    NSRect *virtualSize = &current->size;
    NSRect frame = [self bounds];

    CGFloat midX = virtualSize->origin.x
                 + virtualSize->size.width / 2.0;
    CGFloat midY = virtualSize->origin.y
                 + virtualSize->size.height / 2.0;

    virtualSize->size.width = mini( virtualSize->size.width * (1 + x)
                                 , frame.size.width );
    virtualSize->size.height = mini( virtualSize->size.height * (1 + y)
                                  , frame.size.height );
    CGFloat halfWidth = virtualSize->size.width  / 2.0f;
    CGFloat halfHeight = virtualSize->size.height / 2.0f;

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

    virtualSize->origin.x = midX - halfWidth;
    virtualSize->origin.y = midY - halfHeight;
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

- (SVDrawInfo)searchWithFunction:(SelectFunction)f
                        fromRoot:(NSURL*)url
                      withResult:(SVLayoutLeaf**)rez
{
    NSRect frame = [self bounds];

    SVDrawInfo info =
        { .limit = &current->size
        , .gatherer = nil
        , .minimumWidth = [geometry virtualPixelWidthSize]
        , .minimumHeight = [geometry virtualPixelHeightSize]
        , .wheel = nil
        , .selection = { .name = url
                       , .node = nil
                       , .isFile = FALSE
                       , .layoutNode = nil
                       }
        , .depth = 0
        };
    

    [info.selection.name retain];

    if (rez) *rez = f(&info, &frame);
    else f(&info, &frame);

    return info;
}

- (void)selectWithFunction:(SelectFunction)f
                  fromRoot:(NSURL*)url
{
    SVLayoutLeaf *foundNode;

    SVDrawInfo info =
        [self searchWithFunction:f
                        fromRoot:url
                      withResult:&foundNode];
    
    SVFileTree  *found = [foundNode fileNode];
    
    if ( selected == nil || found != selected->file )
    {
        [selected release];
        selected = [[SVNodeState  alloc] 
                initWithUrl:info.selection.name
                       file:found
                     layout:foundNode
                       size:info.selection.rect];
        [selected retain];
        
        isSelectionFile = info.selection.isFile;
        [self updateGeometry];
        [self setNeedsDisplay:YES];

        NSWindow *window = [self window];

        [window setRepresentedURL:selected->url];
        [window setTitle:[selected->url lastPathComponent]];
        [pathView setURL:selected->url];
        
        stateChangeNotifier();
    }
}

- (void)selectAtPoint:(NSPoint)p
{
    [self selectWithFunction:^SVLayoutLeaf*(SVDrawInfo* i,NSRect *b) {
        return [current->layout getNodeAtPoint:p
                                      withInfo:i
                                     andBounds:b];
    }
                    fromRoot:current->url];
}

- (BOOL)becomeFirstResponder { return YES; }
- (BOOL)resignFirstResponder { return YES; }
- (BOOL)acceptsFirstResponder { return YES; }
- (BOOL)needsPanelToBecomeKey  { return YES; }
- (BOOL)isOpaque { return YES; }
- (BOOL)wantsDefaultClipping { return NO; }

- (IBAction)selectSubItem:(id)sender
{
    NSRect currentRect = current->size;
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
    NSRect currentRect = current->size;

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
    if ( selected == nil )
        return;
    
    NSString *parentFolder =
        [[selected->url URLByDeletingLastPathComponent] path];

    [[NSWorkspace sharedWorkspace] selectFile:[selected->url path]
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
    NSRect prevRect = current->size;

    [self stretchBy:amount andBy:amount];
    zoomAnim =
        [[AnimationPerFrame alloc] initWithView:self
                                       fromRect:prevRect
                                         toRect:current->size
                                    andDuration:0.10f];
    animationKind = AnimationZoom;
    current->size = prevRect;
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

- (void)animateZoom:(AnimationEnd)animation
               from:(NSRect)from
                 to:(NSRect)to
{
    if ( lockAnyMouseEvent ) return;

    animationKind = animation;

    zoomAnim =
        [[AnimationPerFrame alloc] initWithView:self
                                       fromRect:from
                                         toRect:to
                                    andDuration:0.25f];

    [zoomAnim startAnimation];
    [self updateScrollerPosition];
    stateChangeNotifier();
}

- (void)narrowSelected
{
    if ( isSelectionFile ) return;
    [self animateZoom:AnimationNarrow
                 from:current->size
                   to:selected->size];
}

- (void) focusOn:(NSURL*)url
{

    NSArray *toParts = [url pathComponents];
    NSArray *rootParts = [root->url pathComponents];
    NSArray *currentParts = [current->url pathComponents];

    // need rescan, don't care
    if ( [toParts count] < [rootParts count] )
        return;

    if ( [toParts count] < [currentParts count] )
    {   // search node from root.
        SelectFunction func =
          ^ SVLayoutLeaf* (SVDrawInfo* i,NSRect *b) {
            return [root->layout getNodeAtPathParts:toParts
                                        beginningAt:[rootParts count] - 1
                                           withInfo:i
                                          andBounds:b];
        };

        [self selectWithFunction:func
                        fromRoot:root->url];
        
        [current release];
        current = selected;
        [current retain];

        SelectFunction selecSearch = 
          ^ SVLayoutLeaf* (SVDrawInfo* i,NSRect *b) {
            return [root->layout getNodeAtPathParts:currentParts
                                        beginningAt:[rootParts count] - 1
                                           withInfo:i
                                          andBounds:b];
        };

        // size of current selection
        NSRect to =
        ([self searchWithFunction:selecSearch
                         fromRoot:selected->url
                       withResult:nil]).selection.rect;
        
        current->size = to;
        
        [self animateZoom:AnimationNarrow
                     from:to
                       to:[self bounds]];
    }
    else // search node from current.
    {
        SelectFunction func =
            ^ SVLayoutLeaf* (SVDrawInfo* i,NSRect *b) {
            return [current->layout getNodeAtPathParts:toParts
                                           beginningAt:[currentParts count]
                                              withInfo:i
                                             andBounds:b];
            };
        
        [self selectWithFunction:func
                        fromRoot:current->url];

        [self animateZoom:AnimationNarrow
                     from:current->size
                       to:selected->size];
    }
}

- (void)popNarrowing
{
    if ( lockAnyMouseEvent ) return;
    [self focusOn:[current->url URLByDeletingLastPathComponent]];
}

- (BOOL)isZoomMinimum { return root == nil; }
- (BOOL)isZoomMaximum { return root == nil; }

- (BOOL)isSelectionNarrowable
{
    return root != nil && selected != nil && selected->url && !isSelectionFile;
}

- (BOOL)isAtTopLevel
{
    return root == nil || root == current;
}

- (BOOL)isSelectionReavealableInFinder
{
    return selected != nil;
}

- (void)deleteSelection:(BOOL)putInTrash
{
    SVLayoutNode *masterLayout;

    masterLayout = root->layout;

    NSArray *rootComp = [root->url pathComponents];
    NSArray *selRoot = [selected->url pathComponents];
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
    
    if ( selected == root )
    {
        [root release];
        root = nil;

        [current release];
        current = nil;

        [parentControler notifyViewCleanup];
        [[self window] setRepresentedURL:nil];
        [pathView setURL:nil];
    }
    else
    {
        [selected release];
        selected = current;
        [selected retain];

        [pathView setURL:selected->url];
    }


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
    [self
        focusOn:[[pathView clickedPathComponentCell] URL]];
}
@end

