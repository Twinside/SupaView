#import <Cocoa/Cocoa.h>
#import "SVLayoutTree.h"
#import "../SVGraphViz.h"

@interface SVDynamicFileTree : SVFileTree {
}
- (void)updateDiskSize:(FileSize)newFileSize;
@end

@interface SVVolume : SVFileTree {
    SVFolderTree      *child;
    FileSize          volumeSize;
    SVFileTree        *emptySpace;
    SVDynamicFileTree *unscannedSpace;
}

- (id)initWithFilePath:(NSURL*)treeName
            andContext:(SVScanningContext*)ctxt;

- (void)dealloc;
- (SVLayoutTree*)createLayoutTree;
@end
