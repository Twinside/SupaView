#import "Definitions.h"
#import <Cocoa/Cocoa.h>
#import "SVFileTree.h"
#import "SVGeometryGatherer.h"
#import "SVGraphViz.h"


@class SVFileTree;
@class SVColorWheel;
@class SVLayoutTree;

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
    int             depth;
} SVDrawInfo;

@interface SVLayoutTree : NSObject <SVGraphViz> {
    SVLayoutTree  *left;
    SVLayoutTree  *right;
    SVFileTree    *fileNode;

    /**
     * Split size, int [0;1]
     */
    float       splitPos;
    LayoutKind  orientation;
}

- (id)initWithFileList:(NSArray*)fileList
               forNode:(SVFileTree*)t
          andTotalSize:(FileSize)totalSize;

- (id)initWithFile:(SVFileTree*)file;
- (int)countRectNeed;
- (void)dealloc;

- (SVFileTree*)getSelected:(NSPoint)point
                  withInfo:(SVDrawInfo*)info
                 andBounds:(NSRect*)bounds;

- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds;
@end

