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
        , .selection = { .node = currentSelection
                       , .name = currentURL
                       }
        , .depth = 0
        };

    [viewedTree drawGeometry:&info
                    inBounds:&frame];

    [geometry stopGathering];
}

@end
