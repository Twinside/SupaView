#import "../Definitions.h"
#import <Cocoa/Cocoa.h>
#import "../FileTree/SVFileTree.h"
#import "SVGeometryGatherer.h"

@class SVFileTree;
@class SVColorWheel;
@class SVLayoutNode;
@class SVLayoutLeaf;

typedef struct SVSelectionInfo_t
{
    SVFileTree      *node;
    SVLayoutLeaf    *layoutNode;
    NSURL           *name;
    NSRect          rect;
    BOOL            isFile;

} SVSelectionInfo;

typedef struct SVDrawInfo_t
{
    /**
     * Virtual bounds used to cull drawing.
     */
    NSRect  *limit;

    SVGeometryGatherer *gatherer;

    /**
     * Limit size after which it's not useful to draw
     * anything.
     */
    CGFloat minimumWidth;
    CGFloat minimumHeight;

    SVSelectionInfo selection;
    SVColorWheel    *wheel;

    int             depth;
} SVDrawInfo;

NSComparator SvLayoutNodeComparer;

@interface SVLayoutNode : NSObject {
}

- (SVLayoutLeaf*)getSelected:(NSPoint)point
                  withInfo:(SVDrawInfo*)info
                 andBounds:(NSRect*)bounds;

- (BOOL)drawableWithInfo:(SVDrawInfo*)info
                inBounds:(NSRect*)bounds;

- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds;

- (FileSize)nodeSize;
- (SVFileTree*)fileNode;
@end

