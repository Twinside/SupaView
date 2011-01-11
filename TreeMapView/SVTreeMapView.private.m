#import "SVTreeMapView.private.h"
#import "../SVSizes.h"
#import "SVNodeState.h"

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
    if (current == nil)
        return;
    
    NSRect frame = [self frame];
    [geometry startGathering:&frame
                    inBounds:&current->size];
    
    SVDrawInfo info =
        { .limit = &current->size
        , .gatherer = geometry
        , .minimumWidth = [geometry virtualPixelWidthSize]
        , .minimumHeight = [geometry virtualPixelHeightSize]
        , .wheel = wheel
        , .selection = { .node = selected ? selected->file : nil
                       , .name = selected ? selected->url : nil
                       }
        , .depth = 0
        };

    [current->layout drawGeometry:&info
                         inBounds:&frame];

    [geometry stopGathering];
}

@end

