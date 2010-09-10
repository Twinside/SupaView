
#import "SVFileTree.h"
#import "SVColorWheel.h"
#import "SVSizes.h"

inline static
BOOL intersect( NSRect *a, NSRect *b )
{
    CGFloat aRight = a->origin.x + a->size.width;
    CGFloat aTop = a->origin.y + a->size.height;
    
    CGFloat bRight = b->origin.x + b->size.width;
    CGFloat bTop = b->origin.y + b->size.height;
    
    return (a->origin.y <= bTop)
        && (a->origin.x <= bRight)
        && (aRight >= b->origin.x)
        && (aTop >= b->origin.y);
}

@implementation SVLayoutTree
- (LayoutKind)computeOrientationWithWidth:(CGFloat)w
                                   height:(CGFloat)h {
    if (w > h)
        return LayoutHorizontal;
    else
        return LayoutVertical;
}

- (id)initWithFile:(SVFileTree*)file {
    self = [super init];
    left = nil;
    right = nil;
    splitPos = -50.0f;
    fileNode = file;
    
    return self;
}

- (int)countRectNeed {
    int count = (fileNode != 0) ? 1 : 0;
    
    if (left != nil)
        count += [left countRectNeed];
    
    if (right != nil)
        count += [right countRectNeed];
    
    return count;
}

- (id)initWithFileList:(NSArray*)fileList
               forNode:(SVFileTree*)t
          andTotalSize:(FileSize)totalSize {
    self = [super init];
    left = nil;
    right = nil;
    splitPos = -40.0f;
    fileNode = t;

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
        if ([elem getDiskSize] == 0)
            break;
        
        if ( leftSize < midPoint || leftSize == 0 )
        {
            [leftList addObject:elem];
            leftSize += [elem getDiskSize];
        }
        else
            [rightList addObject:elem];
    }

    assert( [leftList count] > 0 );
    assert( [leftList count] < subSize || [leftList count] == 1 );
    assert( [rightList count] < subSize || [leftList count] == 1 );
    
    splitPos = (totalSize > 0) 
             ? (((float)leftSize) / ((float)totalSize))
             : 0.0f;
    
    SVLayoutTree *tempLeft, *tempRight;

    if ( [leftList count] == 1 )
        tempLeft = [[leftList objectAtIndex:0] createLayoutTree];
    else
        tempLeft =
            [[SVLayoutTree alloc] initWithFileList:leftList
                                        forNode:nil
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
                                               forNode:nil
                                          andTotalSize:totalSize - leftSize];
            break;
    }
        

    [leftList release];
    [rightList release];
    left = tempLeft;
    right = tempRight;

    return self;
}

- (void)dealloc
{
    [left release];
    [right release];
    [fileNode release];
    [super dealloc];
}

- (void)cropSubRectangle:(NSRect*)r
{
    if ( fileNode != nil )
    {
        /*
        if () {
            // booya
        } // */
        r->origin.x    += blockSizes.leftMargin;
        r->size.width  -= (blockSizes.leftMargin 
                           + blockSizes.rightMargin);

        r->origin.y    += blockSizes.bottomMargin;
        r->size.height -= (blockSizes.bottomMargin
                            + blockSizes.topMargin);
    }
    else
    {
        r->origin.x += blockSizes.divideLeftMargin;
        r->size.width -= (blockSizes.divideLeftMargin
                          + blockSizes.divideRightMargin);

        r->origin.y    += blockSizes.divideBottomMargin;
        r->size.height -= (blockSizes.divideBottomMargin
                            + blockSizes.divideTopMargin );
    }

}

- (void)drawGeometry:(SVDrawInfo)info
            inBounds:(NSRect*)bounds
{
    // if we are currently not in the good zoom level.
    if (!intersect(bounds, info.limit))
        return;
        
    orientation =
        [self computeOrientationWithWidth:bounds->size.width
                                   height:bounds->size.height];
    
    // if we are smaller than a pixel, don't
    // bother drawing ourselves
    if (bounds->size.width < info.minimumWidth
     || bounds->size.height < info.minimumHeight)
        return;

    if (fileNode != nil)
    {
        [info.gatherer addRectangle:bounds
                          withColor:[info.wheel getLevelColor]];

        if ( bounds->size.height > blockSizes.textHeight )
        {
            NSRect textPos = *bounds;
            textPos.origin.x += blockSizes.textLeftMargin;
            textPos.origin.y += textPos.size.height 
                              - (blockSizes.textHeight 
                                 + blockSizes.textTopMargin);

            textPos.size.height = blockSizes.textHeight;

            [info.gatherer addText:[fileNode filename]
                            inRect:&textPos];
        }
    }
    
    // we have no child <=> we are a
    // file.
    if ( left == nil && right == nil )
        return;

    assert( splitPos > 0.0 );
    assert( splitPos <= 1.0 );
    
    NSRect leftSub = *bounds;
    NSRect rightSub = leftSub;

    switch (orientation)
    {
    case LayoutVertical:
        leftSub.size.height *= splitPos; 
        rightSub.size.height = bounds->size.height - leftSub.size.height;
        rightSub.origin.y += leftSub.size.height;
        break;
        
    case LayoutHorizontal:
        leftSub.size.width *= splitPos;
        rightSub.size.width = bounds->size.width - leftSub.size.width;
        rightSub.origin.x += leftSub.size.width;
        break;
    }
        
    [self cropSubRectangle:&leftSub];
    [self cropSubRectangle:&rightSub];

    [info.wheel pushColor];
    
    [left drawGeometry:info inBounds:&leftSub];
    [right drawGeometry:info inBounds:&rightSub];
    
    [info.wheel popColor];
}

- (void)dumpToFile:(FILE*)f
{
    fprintf( f, "p%p -> p%p\n", self, left );
    fprintf( f, "p%p -> p%p\n", self, right );

    if ( fileNode )
        fprintf( f, "p%p [label=\"%f|%s|%s\", shape=record]\n"
               , self
               , splitPos
               , (orientation == LayoutHorizontal) ? "horiz" : "vert"
               , [[fileNode filename] UTF8String]);
    else
        fprintf( f, "p%p [label=\"%f|%s\", shape=record]\n"
               , self
               , splitPos 
               , (orientation == LayoutHorizontal) ? "horiz" : "vert"
               );

    [left dumpToFile:f];
    [right dumpToFile:f];
}
@end

