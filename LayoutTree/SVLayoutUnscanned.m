#import "SVLayoutUnscanned.h"
#import "../SVColorWheel.h"
#import "SVLayoutLeaf.protected.h"

@implementation SVLayoutUnscanned
- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds
{
    [info->gatherer addRectangle:bounds
                    withColor:[NSColor whiteColor]];

    [self drawFileName:info inBounds:bounds];
}

- (SVFileTree*)fileNode { return nil;  }
@end

