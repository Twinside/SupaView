
#include "FileTree.h"

@implementation LayoutTree


- (id)initWithFileList:(NSArray*)fileList
          andTotalSize:(FileSize)totalSize
{
    self = [super init];
    left = nil;
    right = nil;
    fileNode = nil;

    int     subSize = [fileList count];

    NSMutableArray  *leftList =
        [[NSMutableArray alloc] initWithCapacity:subSize];
    NSMutableArray  *rightList =
        [[NSMutableArray alloc] initWithCapacity:subSize];

    uint64_t    leftSize = 0;
    for ( FileTree *elem in fileList )
    {
        leftSize += [elem getDiskSize];

        if ( leftSize * 2 < totalSize )
            [leftList addObject:elem];
        else
            [rightList addObject:elem];
    }

    left =
        [[LayoutTree alloc] initWithFileList:leftList 
                                andTotalSize:leftSize];
    right =
        [[LayoutTree alloc] initWithFileList:rightList 
                                andTotalSize:totalSize - leftSize];
    
    splitPos = (float)leftSize / (float)totalSize;

    [leftList release];
    [rightList release];
    return self;
}

- (void)dealloc {
    [left release];
    [right release];
    [fileNode release];
    [super dealloc];
}
@end

