
#import "SVTreeMapView.private.h"
#import "SVTreeMapView.animate.h"

@implementation SVTreeMapView (ZoomAnimation)
- (BOOL)animationShouldStart:(NSAnimation *)animation
    { return TRUE; }

- (void)animationDidEnd:(NSAnimation*)animation
{
    virtualSize = [self bounds];
    
    viewedTree = selectedLayoutNode;
    [currentURL release];
    currentURL = selectedURL;
    [currentURL retain];
    
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (void)setVirtualSize:(NSRect)rect
{
    virtualSize = rect;
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (NSRect)virtualSize { return virtualSize; }
@end

