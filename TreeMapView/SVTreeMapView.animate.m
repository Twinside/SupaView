
#import "SVTreeMapView.private.h"
#import "SVTreeMapView.animate.h"

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
        viewedTree = (SVLayoutNode*)selectedLayoutNode;
        [currentURL release];
        currentURL = selectedURL;
        [currentURL retain];
        [self updateGeometry];
        [self setNeedsDisplay:YES];
        break;

    case AnimationPopNarrow:
        virtualSize = [self bounds];
        [self updateGeometry];
        [self setNeedsDisplay:YES];
        break;

    case AnimationZoom:
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
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (NSRect)virtualSize { return virtualSize; }
@end

