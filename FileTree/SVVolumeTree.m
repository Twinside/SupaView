#import "SVVolumeTree.h"
#import "SVFolderTree.h"
#import "SVEmptyNode.h"
#import "SVUnscanned.h"
#import "../LayoutTree/SVLayoutFolder.h"

@implementation SVVolume
- (id)initWithFilePath:(NSURL*)treeName
            andContext:(SVScanningContext*)ctxt
{
    self = [super initWithFilePath:treeName];
    emptySpace = 0;
    volumeSize = 0;
    child = nil;
    
    NSDictionary* fileAttributes =
        [[NSFileManager defaultManager]
                attributesOfFileSystemForPath:[treeName path]
                                        error:nil];

    FileSize emptySpaceSize =
        [[fileAttributes objectForKey:NSFileSystemFreeSize] longLongValue];

    volumeSize = [[fileAttributes objectForKey:NSFileSystemSize]
                                longLongValue];
    emptySpace=
        [[SVEmptyNode alloc] initWithFileSize:emptySpaceSize];

    unscannedSpace =
        [[SVUnscannedTree alloc] init];
    
    child = [SVFolderTree alloc];
    
    [child initWithFilePath:treeName andContext:ctxt];
    
    return self;
}

- (void)dealloc
{
    [emptySpace release];
    [unscannedSpace release];
    [child release];
    [super dealloc];
}

- (SVLayoutTree*)createLayoutTree
{
    FileSize    scannedSize = [child diskSize];
    NSMutableArray *nodeList =
        [[NSMutableArray alloc] initWithCapacity:3];

    [unscannedSpace updateDiskSize: volumeSize
                                  - scannedSize
                                  - [emptySpace diskSize]];

    [nodeList addObject:child];
    [nodeList addObject:emptySpace];
    [nodeList addObject:unscannedSpace];

    [nodeList sortUsingComparator:SvFileTreeComparer];

    SVLayoutTree *layout = 
        [[SVLayoutFolder alloc] initWithFileList:nodeList
                                         forNode:self
                                    andTotalSize:volumeSize];
    [nodeList release];

    return layout;
}
@end

