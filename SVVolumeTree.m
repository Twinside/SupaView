#import "SVVolumeTree.h"

@implementation SVDynamicFileTree
- (void)updateDiskSize:(FileSize)newFileSize
    { diskSize= newFileSize; }
@end

@implementation SVVolume

- (id)initWithFilePath:(NSURL*)treeName
            andContext:(SVScanningContext*)ctxt;
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
        [[SVFileTree alloc] initWithFileName:@"Empty space"
                                     andSize:emptySpaceSize];
    unscannedSpace =
        [[SVDynamicFileTree alloc] initWithFileName:@"Unscanned"
                                            andSize:0];
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
        [[SVLayoutTree alloc] initWithFileList:nodeList
                                       forNode:self
                                  andTotalSize:volumeSize];
    [nodeList release];

    return layout;
}
@end
