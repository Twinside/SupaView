#import <Cocoa/Cocoa.h>
#import "SVLayoutTree.h"
#import "SVFolderTree.h"
#import "SVScanningContext.h"
#import "SVDynamicFileTree.h"
#import "SVScanningContext.h"
#import "../SVGraphViz.h"

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

