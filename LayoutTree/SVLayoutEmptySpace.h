#import "SVLayoutLeaf.h"

/**
 * Used to represent a volume empty space.
 * Only draw "Empty" and it's size.
 */
@interface SVLayoutEmptySpace : SVLayoutLeaf
- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds;
@end

