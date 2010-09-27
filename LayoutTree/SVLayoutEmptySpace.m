#import "SVLayoutEmptySpace.h"

@implementation SVLayoutEmptySpace
- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds
{
    [self drawFileName:info inBounds:bounds];
}

@end
