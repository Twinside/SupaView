#import "Definitions.h"
#import <Cocoa/Cocoa.h>
#import "SVFileTree.h"
#import "SVGeometryGatherer.h"


@class FileTree;


@interface LayoutTree : NSObject {
    LayoutTree  *left;
    LayoutTree  *right;
    FileTree    *fileNode;

    /**
     * Split size, int [0;1]
     */
    float       splitPos;
    LayoutKind  orientation;
}

- (id)initWithFileList:(NSArray*)fileList
          andTotalSize:(FileSize)totalSize;

- (id)initWithFile:(FileTree*)file;
- (int)countRectNeed;
- (void)dealloc;
- (void)drawGeometry:(GeometryGatherer*)gatherer
            inBounds:(NSRect*)bounds;

@end

