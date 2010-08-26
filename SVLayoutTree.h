#import "Definitions.h"
#import <Cocoa/Cocoa.h>
#import "SVFileTree.h"
#import "SVGeometryGatherer.h"
#import "SVGraphViz.h"


@class SVFileTree;
@class SVColorWheel;


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
- (void)drawGeometry:(SVGeometryGatherer*)gatherer
           withColor:(SVColorWheel*)wheel
            inBounds:(NSRect*)bounds;

@end

