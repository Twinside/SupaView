
#import "SVTreeMapView.private.h"
#import "SVTreeMapView.animate.h"

@implementation SVTreeMapView (ZoomAnimation)
- (BOOL)animationShouldStart:(NSAnimation *)animation
    { return TRUE; }

- (void)animationDidEnd:(NSAnimation*)animation
{
    virtualSize = [self bounds];
    [self updateGeometrySize];
    [self setNeedsDisplay:YES];
}

- (void)setVirtualSize:(NSRect)rect
{
    virtualSize = rect;
    [self updateGeometrySize];
    [self setNeedsDisplay:YES];
}

- (NSRect)virtualSize { return virtualSize; }
@end

