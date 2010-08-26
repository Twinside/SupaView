
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

    FileSize     subSize = [fileList count];

    assert( subSize > 0 );
    
    if (subSize == 1)
    {
        fileNode = [fileList objectAtIndex:(NSUInteger)0];
        left = [fileNode createLayoutTree];
        return self;
    }

    NSMutableArray  *leftList =
        [[NSMutableArray alloc] initWithCapacity:subSize];
    NSMutableArray  *rightList =
        [[NSMutableArray alloc] initWithCapacity:subSize];

    uint64_t    leftSize = 0;
    uint64_t    midPoint = totalSize / 2;
    
    for ( FileTree *elem in fileList )
    {
        if ( leftSize < midPoint || leftSize == 0 )
        {
            [leftList addObject:elem];
            leftSize += [elem getDiskSize];
            
            // for now
            assert( [elem getDiskSize] > 0 );
        }
        else
            [rightList addObject:elem];
    }

    assert( [leftList count] > 0 );
    assert( [leftList count] < subSize );
    assert( [rightList count] > 0 );
    assert( [rightList count] < subSize );
    assert( [leftList count] + [rightList count] == subSize );
    
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

    int leftMargin = 2;
    int rightMargin = 2;
    int topMargin = 2;
    int bottomMargin = 2;

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
        
        leftSub.origin.x += leftMargin;
        leftSub.size.width -= (leftMargin + rightMargin);

        leftSub.origin.y += bottomMargin;
        leftSub.origin.y -= (bottomMargin + topMargin);

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
        rightSub.origin.x += leftMargin;
        rightSub.size.width -= (leftMargin + rightMargin);

        rightSub.origin.y += bottomMargin;
        rightSub.origin.y -= (bottomMargin + topMargin);
        
        [right drawGeometry:gatherer inBounds:&rightSub];
    }
}

@end

