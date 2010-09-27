#import "SVLayoutNode.h"

@interface SVLayoutTree : SVLayoutNode {
    SVLayoutNode  *left;
    SVLayoutNode  *right;

    /**
     * Split size, int [0;1]
     */
    float       splitPos;
    LayoutKind  orientation;
}
- (id)initWithFileList:(NSArray*)fileList
          andTotalSize:(FileSize)totalSize;

- (void)dealloc;
- (SVLayoutLeaf*)getSelected:(NSPoint)point
                    withInfo:(SVDrawInfo*)info
                   andBounds:(NSRect*)bounds;

- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds;
@end

