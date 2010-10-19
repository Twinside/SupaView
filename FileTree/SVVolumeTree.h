#import <Cocoa/Cocoa.h>
#import "SVLayoutTree.h"
#import "SVFolderTree.h"
#import "SVScanningContext.h"
#import "SVDynamicFileTree.h"
#import "SVScanningContext.h"
#import "../SVGraphViz.h"

/**
 * Represent a volume (hard disk). Extract
 * more information from the system in order
 * to display them and give advancement
 * information */
@interface SVVolume : SVFileTree {
    SVFolderTree      *child;
    FileSize          volumeSize;
    SVFileTree        *emptySpace;
    SVDynamicFileTree *unscannedSpace;
}

- (id)initWithFilePath:(NSURL*)treeName
            andContext:(SVScanningContext*)ctxt;

- (void)dealloc;
- (SVLayoutNode*)createLayoutTree:(int)maxDepth
                          atDepth:(int)depth;
- (double)advancementPercentage;
@end

