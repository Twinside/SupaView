#import "SVFileTree.h"
#import "SVScanningContext.h"

@interface SVFolderTree : SVFileTree {
    NSMutableArray     *children;
}

- (id)initWithFilePath:(NSURL*)treeName
            andContext:(SVScanningContext*)ctxt;

- (void)dealloc;

- (SVFolderTree*)addChild:(SVFileTree*)subTree;
- (void) populateChildListAtUrl:(NSURL*)url
                    withContext:(SVScanningContext*)ctxt;

- (SVLayoutTree*)createLayoutTree;
@end

