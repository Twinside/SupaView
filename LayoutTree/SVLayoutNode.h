#import "Definitions.h"
#import <Cocoa/Cocoa.h>
#import "SVFileTree.h"
#import "SVGeometryGatherer.h"

@class SVFileTree;
@class SVColorWheel;
@class SVLayoutNode;
@class SVLayoutLeaf;

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

    SVColorWheel    *wheel;
    SVFileTree      *selected;

    NSURL           *selectedName;
    NSRect          selectionRect;
    BOOL            selectedIsFile;
    int             depth;
} SVDrawInfo;

@interface SVLayoutNode : NSObject {
}

- (SVLayoutLeaf*)getSelected:(NSPoint)point
                  withInfo:(SVDrawInfo*)info
                 andBounds:(NSRect*)bounds;

- (BOOL)drawableWithInfo:(SVDrawInfo*)info
                inBounds:(NSRect*)bounds;

- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds;
@end

