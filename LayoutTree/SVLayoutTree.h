#import "SVLayoutNode.h"

/**
 * Main class of the layouyt tree.
 * When drawing, split the given rectangle
 * in two pieces, of proportion given by
 * splitPos.
 */
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

- (void)splitRectangles:(NSRect*)leftSub and:(NSRect*)rightSub;
@end

