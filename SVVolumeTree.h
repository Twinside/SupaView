#import <Cocoa/Cocoa.h>
#import "SVLayoutTree.h"
#import "SVGraphViz.h"


@interface SVVolume : SVFileTree {
    SVFolderTree    *child;
    FileSize        emptySpace;
    FileSize        volumeSize;
}

- (id)initWithFilePath:(NSURL*)treeName
            andContext:(SVScanningContext*)ctxt;

- (SVLayoutTree*)createLayoutTree;
@end
