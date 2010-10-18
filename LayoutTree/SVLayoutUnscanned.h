#import "SVLayoutLeaf.h"

/**
 * Draw the yet unscanned space if a volume is scanned.
 * Draw a border, "Unscanned" and it's size.
 */
@interface SVLayoutUnscanned : SVLayoutLeaf
- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds;
- (SVFileTree*)fileNode;
@end

