
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

inline static
BOOL intersect( const NSRect *a, const NSRect *b )
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

inline static
NSString * stringFromFileSize( FileSize theSize )
{
	float floatSize = theSize;
	if (theSize<1023)
		return([NSString stringWithFormat:@"%i bytes",theSize]);
	floatSize = floatSize / 1024;
	if (floatSize<1023)
		return([NSString stringWithFormat:@"%1.1f KB",floatSize]);
	floatSize = floatSize / 1024;
	if (floatSize<1023)
		return([NSString stringWithFormat:@"%1.1f MB",floatSize]);
	floatSize = floatSize / 1024;

	return([NSString stringWithFormat:@"%1.1f GB",floatSize]);
}

@interface SVLayoutTree (RectSplitting)
- (void)splitRectangles:(NSRect*)leftSub and:(NSRect*)rightSub;
- (void)cropSubRectangle:(NSRect*)r withInfo:(SVDrawInfo*)info;
- (BOOL)textDrawableInBounds:(NSRect*)bounds andInfo:(SVDrawInfo*)info;
@end

@implementation SVLayoutTree (RectSplitting)
- (void)cropSubRectangle:(NSRect*)r withInfo:(SVDrawInfo*)info {
    CGFloat miniWidth = info->minimumWidth;
    CGFloat miniHeight = info->minimumHeight;

    if ( fileNode == nil )
        return;

    r->origin.x    += blockSizes.leftMargin * miniWidth;
    r->size.width  -= (blockSizes.leftMargin 
                        + blockSizes.rightMargin) * miniWidth;

    r->origin.y    += blockSizes.bottomMargin * miniHeight;

    if ( [self textDrawableInBounds:r andInfo:info] )
        r->size.height -= (blockSizes.bottomMargin
                            + blockSizes.topMargin
                            + blockSizes.textHeight) * miniHeight;
    else
        r->size.height -= (blockSizes.bottomMargin
                            + blockSizes.topMargin) * miniHeight;
}

- (BOOL)textDrawableInBounds:(NSRect*)bounds andInfo:(SVDrawInfo*)info {
    return bounds->size.height >= blockSizes.textHeight * info->minimumHeight
        && bounds->size.width >= blockSizes.textMinimumWidth * info->minimumHeight;
}

- (void)splitRectangles:(NSRect*)leftSub and:(NSRect*)rightSub {
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
@end

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

    // ignore this previous assertion to permit live
    // drawing
    if ( [leftList count] == 0
        || [leftList count] == subSize)
        return self;
    
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

- (void)dealloc {
    [left release];
    [right release];
    [super dealloc];
}

- (void)drawNodeText:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds
{
    NSRect textPos = *bounds;

    if ( ![self textDrawableInBounds:bounds
                             andInfo:info] )
        return;

    textPos.origin.x += blockSizes.textLeftMargin * info->minimumWidth;

    // if it's a file, we can't allow multi-line rendering
    if ( left == nil && right == nil )
    {
        textPos.origin.y += (blockSizes.bottomMargin + 1) * info->minimumHeight;
        textPos.size.height =
            textPos.size.height / info->minimumHeight - blockSizes.textTopMargin;
    }
    else // we are in a folder
    {
        textPos.origin.y += textPos.size.height 
                            - (blockSizes.textHeight 
                                + blockSizes.textTopMargin - 1) * info->minimumHeight;
        textPos.size.height = blockSizes.textHeight;
    }

    if ( textPos.size.width > blockSizes.fileSizeMinDisplay * info->minimumWidth )
    {
        CGFloat sizeDisplaySize = blockSizes.fileSizeWidth * info->minimumWidth;

        textPos.size.width -= sizeDisplaySize;
        [info->gatherer addText:[fileNode filename]
                         inRect:&textPos];

        // update to put size information
        textPos.origin.x += textPos.size.width;

        [info->gatherer addText:stringFromFileSize([fileNode getDiskSize])
                         inRect:&textPos];
    }
    else
    {
        textPos.size.width -= 2 * blockSizes.textLeftMargin * info->minimumWidth;
        [info->gatherer addText:[fileNode filename]
                         inRect:&textPos];
    }
}

- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds
{
    // if we are currently not in the good zoom level.
    if (!intersect(bounds, info->limit))
        return;
        
    orientation =
        [self computeOrientationWithWidth:bounds->size.width
                                   height:bounds->size.height];
    
    // if we are smaller than a pixel, don't
    // bother drawing ourselves
    if (bounds->size.width < blockSizes.minBoxSizeWidth * info->minimumWidth
     || bounds->size.height < blockSizes.minBoxSizeHeight * info->minimumHeight)
        return;

    // if we are linked to a folder or a file.
    if (fileNode != nil)
    {
        [info->gatherer addRectangle:bounds
                          withColor:(info->selected == fileNode)
                                    ? [info->wheel getSelectionColor]
                                    : [info->wheel getLevelColor]];

        [self drawNodeText:info inBounds:bounds];
    }
    
    // we have no child <=> we are a
    // file.
    if ( left == nil && right == nil )
        return;

    // to allow live construction  of the tree with unfinished nodes,
    // we just return here the values are bad. (the conditions
    // were previously asserts).
    if ( splitPos < 0.0 || splitPos > 1.0 )
        return;
    
    NSRect subBounds = *bounds;
    [self cropSubRectangle:&subBounds withInfo:info];

    NSRect leftSub = subBounds;
    NSRect rightSub = leftSub;

    [self splitRectangles:&leftSub and:&rightSub];
        
    if (fileNode != nil)
        [info->wheel pushColor];
    
    [left drawGeometry:info inBounds:&leftSub];
    [right drawGeometry:info inBounds:&rightSub];
    
    if (fileNode != nil)
        [info->wheel popColor];
}

- (SVFileTree*)getSelected:(NSPoint)point
                    withInfo:(SVDrawInfo*)info
                   andBounds:(NSRect*)bounds {
        
    orientation =
        [self computeOrientationWithWidth:bounds->size.width
                                   height:bounds->size.height];
    
    if ( fileNode != nil )
    {
        if ( info->depth != 0 )
        {
            NSURL *newName =
                [info->selectedName URLByAppendingPathComponent:[fileNode filename]];

            [info->selectedName release];

            [newName retain];
            info->selectedName = newName;
        }
    }

    if (left == nil && right == nil )
        return fileNode;

    NSRect leftSub = *bounds;
    [self cropSubRectangle:&leftSub withInfo:info];
    NSRect rightSub = leftSub;

    [self splitRectangles:&leftSub and:&rightSub];
    
    SVFileTree* ret = nil;

    info->depth++;
    if ( left && insideRect( &leftSub, &point ) )
        ret = [left getSelected:point withInfo:info andBounds:&leftSub];
    else if ( right && insideRect( &rightSub, &point ) ) // must be in other rect
        ret = [right getSelected:point withInfo:info andBounds:&rightSub];

    info->depth--;
    return ( ret == nil ) ? fileNode : ret;
}

- (void)dumpToFile:(FILE*)f {
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

