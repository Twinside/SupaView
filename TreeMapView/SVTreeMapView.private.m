#import "SVTreeMapView.private.h"
#import "../SVSizes.h"

@implementation SVTreeMapView (Private)
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

@end

