
#include "FileTree.h"

@implementation LayoutTree
- (LayoutKind)computeOrientationWithSize:(FileSize)leftSize
                                 andSize:(FileSize)rightSize
{
    if (leftSize + rightSize <= 0)
        return LayoutHorizontal;

    return true //(width >= height)
            ? LayoutHorizontal
            : LayoutVertical;
}

- (id)initWithFile:(FileTree*)file
{
    self = [super init];
    left = nil;
    right = nil;
    fileNode = file;
    
    return self;
}

- (int)countRectNeed
{
    int count = (fileNode != 0) ? 1 : 0;
    
    if (left != nil)
        count += [left countRectNeed];
    
    if (right != nil)
        count += [right countRectNeed];
    
    return count;

}

- (id)initWithFileList:(NSArray*)fileList
          andTotalSize:(FileSize)totalSize
{
    self = [super init];
    left = nil;
    right = nil;
    fileNode = nil;

    int     subSize = [fileList count];

    if (subSize == 1)
    {
        fileNode = [fileList objectAtIndex:0];
        left = [fileNode createLayoutTree];
        return self;
    }

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
    
    splitPos = (totalSize > 0) 
             ? (float)leftSize / (float)totalSize
             : 0.0f;

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

- (void)drawGeometry:(GeometryGatherer*)gatherer
            inBounds:(NSRect*)bounds
{
    // if we are smaller than a pixel, don't
    // bother drawing ourselves
    if (bounds->size.width < 1.0 || bounds->size.height < 1.0)
        return;

    // we have no child <=> we are a
    // file.
    if ( left == nil && right == nil )
    {
        [gatherer addRectangle:bounds
                     withColor:[NSColor whiteColor]];
        return;
    }

    if (fileNode != nil)
    {
        [gatherer addRectangle:bounds
                     withColor:[NSColor blackColor]];
    }

    if ( left != nil )
    {
        NSRect leftSub = *bounds;
        
        switch (orientation)
        {
        case LayoutVertical:
            leftSub.size.width *= splitPos; 
            break;
            
        case LayoutHorizontal:
            leftSub.size.height *= splitPos;
            break;
        }
        
        [left drawGeometry:gatherer inBounds:&leftSub];
    }
    
    if ( right != nil )
    {
        NSRect rightSub = *bounds;
        
        switch (orientation)
        {
            case LayoutVertical:
                rightSub.origin.x += (1.0 - splitPos) * rightSub.size.width;
                rightSub.size.width *= splitPos;
                break;
                
            case LayoutHorizontal:
                rightSub.origin.y += (1.0 - splitPos) * rightSub.size.height;
                rightSub.size.height *= splitPos;
                break;
        }
        
        [right drawGeometry:gatherer inBounds:&rightSub];
    }
}

@end

