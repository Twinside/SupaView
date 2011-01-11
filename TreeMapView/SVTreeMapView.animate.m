
#import "SVTreeMapView.private.h"
#import "SVTreeMapView.animate.h"
#import "SVTreeMapView.scroller.h"

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
        virtualSize = [self bounds];
        // TODO : fix
        [current release];
        current = selected;
        [current retain];

        [self updateScrollerPosition];
        [self updateGeometry];
        [self setNeedsDisplay:YES];
        break;

    case AnimationPopNarrow:
        virtualSize = [self bounds];
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
    virtualSize = rect;
    [self updateScrollerPosition];
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (NSRect)virtualSize { return virtualSize; }
@end

