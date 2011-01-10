#import "SVLayoutTree.h"
#import "SVFileTree.h"
#import "SVColorWheel.h"
#import "SVSizes.h"

@implementation SVLayoutTree
- (LayoutKind)computeOrientationWithWidth:(CGFloat)w
                                   height:(CGFloat)h {
    if (w > h)
        return LayoutHorizontal;
    else
        return LayoutVertical;
}

- (void)dealloc
{
    [left release];
    [right release];
    [super dealloc];
}

- (id)initWithFileList:(NSArray*)fileList
          andTotalSize:(FileSize)totalSize {
    self = [super init];
    left = nil;
    right = nil;
    splitPos = -40.0f;

    FileSize     subSize = [fileList count];

    assert( subSize > 0 );
    
    // can happen if a folder only got one child
    if ( subSize == 1 )
    {
        left = [fileList objectAtIndex:0];
        [left retain];
        splitPos = 1.0;
        return self;
    }
    
    NSMutableArray  *leftList =
        [[NSMutableArray alloc] initWithCapacity:subSize / 2];
    NSMutableArray  *rightList =
        [[NSMutableArray alloc] initWithCapacity:subSize / 2];

    FileSize    leftSize = 0;
    FileSize    midPoint = totalSize / 2;
    
    // greedy filling of leftList, approximately
    // half of total size.
    for ( SVLayoutNode *elem in fileList )
    {
        if ([elem nodeSize] == 0)
            break;
        
        if ( leftSize < midPoint || leftSize == 0 )
        {
            [leftList addObject:elem];
            leftSize += [elem nodeSize];
        }
        else
            [rightList addObject:elem];
    }

    // ignore this previous assertion to permit live
    // drawing
    if ( [leftList count] == 0
        || [leftList count] == subSize)
    {
        [leftList release];
        [rightList release];
        return self;
    }
    
    splitPos = (totalSize > 0) 
             ? (((float)leftSize) / ((float)totalSize))
             : 0.0f;
    
    if ( [leftList count] == 1 )
    {
        left = [leftList objectAtIndex:0];
        [left retain];
    }
    else
        left =
            [[SVLayoutTree alloc] initWithFileList:leftList
                                      andTotalSize:leftSize];

    // we can have 0 sized right-list
    // because we can have trailing empty folders
    // at the end of the list.
    switch ( [rightList count] ) {
        case 0:
            right = nil;
            break;
            
        case 1:
            right = [rightList objectAtIndex:0];
            [right retain];
            break;
            
        default:
            right =
                [[SVLayoutTree alloc] initWithFileList:rightList
                                          andTotalSize:totalSize - leftSize];
            break;
    }

    [leftList release];
    [rightList release];

    return self;
}

- (void)splitRectangles:(NSRect*)leftSub and:(NSRect*)rightSub
{
    NSRect subBounds = *leftSub;
    switch (orientation & LayoutMask)
    {
    case LayoutVertical:
        leftSub->size.height *= splitPos; 
        rightSub->size.height = subBounds.size.height - leftSub->size.height;
        rightSub->origin.y += leftSub->size.height;
        break;
        
    case LayoutHorizontal:
        leftSub->size.width *= splitPos;
        rightSub->size.width = subBounds.size.width - leftSub->size.width;
        rightSub->origin.x += leftSub->size.width;
        break;
    }
}

- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds
{
    if ( ![self drawableWithInfo:info inBounds:bounds]
       || splitPos < 0.0 || splitPos > 1.0 )
        return;

    orientation &= ~LayoutMask;
    orientation |=
        [self computeOrientationWithWidth:bounds->size.width
                                   height:bounds->size.height];
    
    NSRect leftSub = *bounds;
    NSRect rightSub = *bounds;

    [self splitRectangles:&leftSub and:&rightSub];
        
    [left drawGeometry:info inBounds:&leftSub];
    [right drawGeometry:info inBounds:&rightSub];
}

- (SVLayoutLeaf*)getNodeConforming:(LayoutPredicate)predicate
                          withInfo:(SVDrawInfo*)info
                         andBounds:(NSRect*)bounds
{
    if ( !predicate( self, info, bounds )
       //![self drawableWithInfo:info inBounds:bounds]
       || splitPos < 0.0 || splitPos > 1.0 )
        return nil;

    orientation &= ~LayoutMask;
    orientation |=
        [self computeOrientationWithWidth:bounds->size.width
                                   height:bounds->size.height];

    NSRect leftSub = *bounds;
    NSRect rightSub = *bounds;

    [self splitRectangles:&leftSub and:&rightSub];
    
    SVLayoutLeaf* ret = nil;

    if ( left )
    {
        ret = [left getNodeConforming:predicate
                             withInfo:info
                            andBounds:&leftSub];
        // clear the selection mask
        orientation &= ~SelectionMask;
        orientation |= SelectionAtLeft;
    }

    if ( ret == nil && right ) // must be in other rect
    {
        ret = [right getNodeConforming:predicate
                              withInfo:info
                             andBounds:&rightSub];
        orientation &= ~SelectionMask;
        orientation |= SelectionAtRight;
    }

    return ret;
}

- (SVFileTree*)fileNode
{
    SVFileTree *ret = [left fileNode];

    if ( ret == nil )
        return [right fileNode];

    return ret;
}
@end

