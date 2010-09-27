#import "SVLayoutTree.h"
#import "SVFileTree.h"
#import "SVColorWheel.h"
#import "SVSizes.h"

inline static
BOOL insideRect( const NSRect *r, const NSPoint *p )
{
    return (r->origin.x <= p->x)
        && (r->origin.y <= p->y)
        && (r->origin.x + r->size.width >= p->x)
        && (r->origin.y + r->size.height >= p->y);
}

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
        left = [[fileList objectAtIndex:0] createLayoutTree];
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
    for ( SVFileTree *elem in fileList )
    {
        if ([elem diskSize] == 0)
            break;
        
        if ( leftSize < midPoint || leftSize == 0 )
        {
            [leftList addObject:elem];
            leftSize += [elem diskSize];
        }
        else
            [rightList addObject:elem];
    }

    // ignore this previous assertion to permit live
    // drawing
    if ( [leftList count] == 0
        || [leftList count] == subSize)
        return self;
    
    splitPos = (totalSize > 0) 
             ? (((float)leftSize) / ((float)totalSize))
             : 0.0f;
    
    SVLayoutNode *tempLeft, *tempRight;

    if ( [leftList count] == 1 )
        tempLeft = [[leftList objectAtIndex:0] createLayoutTree];
    else
        tempLeft =
            [[SVLayoutTree alloc] initWithFileList:leftList
                                      andTotalSize:leftSize];

    // we can have 0 sized right-list
    // because we can have trailing empty folders
    // at the end of the list.
    switch ( [rightList count] ) {
        case 0:
            tempRight = nil;
            break;
            
        case 1:
            tempRight =
                [[rightList objectAtIndex:0] createLayoutTree];
            break;
            
        default:
            tempRight =
                [[SVLayoutTree alloc] initWithFileList:rightList
                                          andTotalSize:totalSize - leftSize];
            break;
    }
        

    [leftList release];
    [rightList release];
    left = tempLeft;
    right = tempRight;

    return self;
}

- (void)splitRectangles:(NSRect*)leftSub and:(NSRect*)rightSub
{
    NSRect subBounds = *leftSub;
    switch (orientation)
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

    orientation =
        [self computeOrientationWithWidth:bounds->size.width
                                   height:bounds->size.height];
    
    NSRect leftSub = *bounds;
    NSRect rightSub = *bounds;

    [self splitRectangles:&leftSub and:&rightSub];
        
    [left drawGeometry:info inBounds:&leftSub];
    [right drawGeometry:info inBounds:&rightSub];
}

- (SVLayoutLeaf*)getSelected:(NSPoint)point
                    withInfo:(SVDrawInfo*)info
                   andBounds:(NSRect*)bounds
{
    if ( ![self drawableWithInfo:info inBounds:bounds]
       || splitPos < 0.0 || splitPos > 1.0 )
        return nil;

    orientation =
        [self computeOrientationWithWidth:bounds->size.width
                                   height:bounds->size.height];

    NSRect leftSub = *bounds;
    NSRect rightSub = *bounds;

    [self splitRectangles:&leftSub and:&rightSub];
    
    SVLayoutLeaf* ret = nil;

    info->depth++;
    if ( left && insideRect( &leftSub, &point ) )
        ret = [left getSelected:point withInfo:info andBounds:&leftSub];
    else if ( right && insideRect( &rightSub, &point ) ) // must be in other rect
        ret = [right getSelected:point withInfo:info andBounds:&rightSub];
    info->depth--;

    return ret;
}
@end

