#import "Definitions.h"
#import <Cocoa/Cocoa.h>
#import "SVLayoutLeaf.h"

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

