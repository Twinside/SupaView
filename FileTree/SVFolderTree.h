#import "SVFileTree.h"
#import "SVScanningContext.h"

/**
 * Store information for a whole folder.
 * Store disk size and a list of it's children.
 */
@interface SVFolderTree : SVFileTree {
    NSMutableArray     *children;
}
- (id)initWithFilePath:(NSURL*)treeName
            andContext:(SVScanningContext*)ctxt;

- (void)dealloc;
- (size_t)childCount;
- (SVLayoutNode*)createLayoutTree;
@end

