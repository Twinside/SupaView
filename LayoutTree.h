
#import <Cocoa/Cocoa.h>
#import "FileTree.h"

typedef enum LayoutKind_t {
    LayoutVertical,
    LayoutHorizontal
} LayoutKind;

@class FileTree;

typedef uint64_t    FileSize;

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

- (void)dealloc;
@end

