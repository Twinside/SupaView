#import "SVVolumeTree.h"

@implementation SVVolume

- (id)initWithFilePath:(NSURL*)treeName
            andContext:(SVScanningContext*)ctxt;
{
    self = [super initWithFilePath:treeName];

    NSDictionary* fileAttributes =
        [[NSFileManager defaultManager]
                attributesOfFileSystemForPath:[treeName path]
                                        error:nil];

    emptySpace = [[fileAttributes objectForKey:NSFileSystemFreeSize]
                                longLongValue];
    volumeSize = [[fileAttributes objectForKey:NSFileSystemSize]
                                longLongValue];
    
    child = [SVFolderTree alloc];
    
    [child initWithFilePath:treeName andContext:ctxt];
    
    return self;
}

- (SVLayoutTree*)createLayoutTree
{
    FileSize    scannedSize = [child getDiskSize];
    NSMutableArray *nodeList =
        [[NSMutableArray alloc] initWithCapacity:3];

    SVFileTree  *emptyNode =
        [[SVFileTree alloc] initWithFileName:@"Empty space"
                                     andSize:emptySpace];
    SVFileTree  *unscannedNode =
        [[SVFileTree alloc] initWithFileName:@"Unscanned"
                                     andSize:volumeSize 
                                            - emptySpace
                                            - scannedSize];


    [nodeList addObject:child];
    [nodeList addObject:emptyNode];
    [nodeList addObject:unscannedNode];

    [nodeList sortUsingComparator:SvFileTreeComparer];

    SVLayoutTree *layout = 
        [[SVLayoutTree alloc] initWithFileList:nodeList
                                       forNode:self
                                  andTotalSize:volumeSize];
    [nodeList release];
    [emptyNode release];
    [unscannedNode release];

    return layout;
}
@end
