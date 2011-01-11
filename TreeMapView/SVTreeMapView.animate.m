
#import "SVTreeMapView.private.h"
#import "SVTreeMapView.animate.h"
#import "SVTreeMapView.scroller.h"
#import "SVNodeState.h"

@implementation SVTreeMapView (ZoomAnimation)
- (BOOL)animationShouldStart:(NSAnimation *)animation
{
    lockAnyMouseEvent = TRUE;
    return TRUE;
}

- (void)animationDidEnd:(NSAnimation*)animation
{
    switch ( animationKind )
    {
    case AnimationNarrow:
        [current release];
        current = selected;
        [current retain];

        current->size = [self bounds];
        [pathView setURL:current->url];

        [self updateScrollerPosition];
        [self updateGeometry];
        [self setNeedsDisplay:YES];
        break;

    case AnimationZoom:
        [self updateScrollerPosition];
        [self updateGeometry];
        [self setNeedsDisplay:YES];
        break;
    }

    [zoomAnim release];
    zoomAnim = nil;
    lockAnyMouseEvent = FALSE;
}

- (void)setVirtualSize:(NSRect)rect
{
    current->size = rect;
    [self updateScrollerPosition];
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (NSRect)virtualSize { return current->size; }
@end

