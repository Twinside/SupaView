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

- (double)advancementPercentage
{
    return ((double)[child diskSize]) / ((double)(volumeSize - [emptySpace diskSize]));
}

- (void)dealloc
{
    [emptySpace release];
    [unscannedSpace release];
    [child release];
    [super dealloc];
}

- (SVLayoutNode*)createLayoutTree:(int)maxDepth
                          atDepth:(int)depth
{
    FileSize    scannedSize = [child diskSize];
    NSMutableArray *nodeList =
        [[NSMutableArray alloc] initWithCapacity:3];

    [unscannedSpace updateDiskSize: volumeSize
                                  - scannedSize
                                  - [emptySpace diskSize]];

    [nodeList addObject:[child createLayoutTree:maxDepth atDepth:depth]];
    [nodeList addObject:[emptySpace createLayoutTree:maxDepth atDepth:depth]];
    [nodeList addObject:[unscannedSpace createLayoutTree:maxDepth atDepth:depth]];

    [nodeList sortUsingComparator:SvLayoutNodeComparer];

    SVLayoutTree *layout = 
        [[SVLayoutTree alloc] initWithFileList:nodeList
                                  andTotalSize:volumeSize];
    [nodeList release];

    return [layout autorelease];
}

- (FileDeleteRez)deleteNodeWithURLParts:(NSArray*)parts
                                atIndex:(size_t)index
{
    NSLog(@"called");
    return makeFileDeleteRez( 0, nil );
}
@end

