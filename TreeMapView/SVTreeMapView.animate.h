#import "SVTreeMapView.h"

@interface SVTreeMapView (ZoomAnimation)
- (void)animationDidEnd:(NSAnimation*)animation;
- (BOOL)animationShouldStart:(NSAnimation *)animation;

- (NSRect)virtualSize;
- (void)setVirtualSize:(NSRect)rect;
@end
