
#import "SVFileTree.h"
#import "SVColorWheel.h"
#import "SVSizes.h"

@implementation SVLayoutTree
- (LayoutKind)computeOrientationWithWidth:(CGFloat)w
                                   height:(CGFloat)h
{
    if (w > h)
        return LayoutHorizontal;
    else
        return LayoutVertical;
}

- (id)initWithFile:(SVFileTree*)file
{
    self = [super init];
    left = nil;
    right = nil;
    splitPos = -50.0f;
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
               forNode:(SVFileTree*)t
          andTotalSize:(FileSize)totalSize
{
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
        [[NSMutableArray alloc] initWithCapacity:subSize];
    NSMutableArray  *rightList =
        [[NSMutableArray alloc] initWithCapacity:subSize];

    uint64_t    leftSize = 0;
    uint64_t    midPoint = totalSize / 2;
    
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
    //assert( [rightList count] > 0 );
    assert( [rightList count] < subSize || [leftList count] == 1 );
    //assert( [leftList count] + [rightList count] == subSize );
    
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
        r->origin.x    += blockSizes.leftMargin;
        r->size.width  -= (blockSizes.leftMargin 
                           + blockSizes.rightMargin);

        r->origin.y    += blockSizes.bottomMargin;
        r->size.height -= (blockSizes.bottomMargin
                            + blockSizes.topMargin);
    }
}

- (void)drawGeometry:(SVGeometryGatherer*)gatherer
           withColor:(SVColorWheel*)wheel
            inBounds:(NSRect*)bounds
{
    orientation =
        [self computeOrientationWithWidth:bounds->size.width
                                   height:bounds->size.height];
    
    // if we are smaller than a pixel, don't
    // bother drawing ourselves
    if (bounds->size.width < 1.0 || bounds->size.height < 1.0)
        return;

    if (fileNode != nil)
    {
        [gatherer addRectangle:bounds
                     withColor:[wheel getLevelColor]];

        if ( bounds->size.height > blockSizes.textHeight )
        {
            NSRect textPos = *bounds;
            textPos.origin.x += blockSizes.textLeftMargin;
            textPos.origin.y += textPos.size.height 
                              - (blockSizes.textHeight 
                                 + blockSizes.textTopMargin);

            textPos.size.height = blockSizes.textHeight;

            [gatherer addText:[fileNode filename]
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

    [wheel pushColor];
    
    [left drawGeometry:gatherer withColor:wheel inBounds:&leftSub];
    [right drawGeometry:gatherer withColor:wheel inBounds:&rightSub];
    
    [wheel popColor];
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

