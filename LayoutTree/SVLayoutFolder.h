#import "Definitions.h"
#import <Cocoa/Cocoa.h>
#import "SVLayoutLeaf.h"

/**
 * This kind of layout tree got a file node associated
 * and only got one layout child. Display folder name,
 * crop the rectangle a bit and let it's child draw.
 */
@interface SVLayoutFolder : SVLayoutLeaf {
    SVLayoutNode    *child;
}
- (id)initWithFileList:(NSArray*)fileList
               forNode:(SVFileTree*)t
          andTotalSize:(FileSize)totalSize;

- (void)dealloc;

- (SVLayoutLeaf*)getSelected:(NSPoint)point
                    withInfo:(SVDrawInfo*)info
                   andBounds:(NSRect*)bounds;

- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds;
@end

