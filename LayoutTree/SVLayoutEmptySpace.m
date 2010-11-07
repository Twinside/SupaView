#import "SVLayoutEmptySpace.h"
#import "SVLayoutLeaf.protected.h"

@implementation SVLayoutEmptySpace
- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds
{
    [info->gatherer addRectangle:bounds
                       withColor:[NSColor windowBackgroundColor]];
    [self drawFileName:info inBounds:bounds];
}

- (SVFileTree*)fileNode { return nil;  }
@end
