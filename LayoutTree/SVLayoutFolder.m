#import "../SVSizes.h"
#import "../SVColorWheel.h"
#import "../LayoutTree/SVLayoutFolder.h"
#import "../LayoutTree/SVLayoutTree.h"
#import "../SVSizeFormatter.h"

@implementation SVLayoutFolder
- (void)dealloc
{
    [child release];
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
    textPos.origin.y += textPos.size.height 
                        - (blockSizes.textHeight 
                            + blockSizes.textTopMargin) * info->minimumHeight;
    textPos.size.height = blockSizes.textHeight;

    if ( textPos.size.width > (blockSizes.fileSizeMinDisplay + blockSizes.textMinimumWidth ) 
                                * info->minimumWidth )
    {
        NSString *sizeString = 
            [[SVSizeFormatter sharedInstance] formatSize:[fileNode diskSize]];

        textPos.size.width -= ([info->gatherer evaluateStringWidth:sizeString]
                              + blockSizes.textLeftMargin)
                            * info->minimumWidth;

        [info->gatherer addText:[fileNode filename]
                         inRect:&textPos];

        // update to put size information
        textPos.origin.x += textPos.size.width;
        
        [info->gatherer addText:sizeString inRect:&textPos];
    }
    else
    {
        textPos.size.width -= 2 * blockSizes.textLeftMargin * info->minimumWidth;
        [info->gatherer addText:[fileNode filename]
                         inRect:&textPos];
    }
}

- (void)cropSubRectangle:(NSRect*)r withInfo:(SVDrawInfo*)info {
    CGFloat miniWidth = info->minimumWidth;
    CGFloat miniHeight = info->minimumHeight;

    if ( fileNode == nil )
        return;

    r->origin.x    += blockSizes.leftMargin * miniWidth;
    r->size.width  -= (blockSizes.leftMargin 
                        + blockSizes.rightMargin) * miniWidth;

    r->origin.y    += blockSizes.bottomMargin * miniHeight;

    r->size.height -= (blockSizes.bottomMargin
                        + blockSizes.topMargin
                        + blockSizes.textHeight) * miniHeight;
}

- (SVLayoutLeaf*)getSelected:(NSPoint)point
                    withInfo:(SVDrawInfo*)info
                   andBounds:(NSRect*)bounds
{
    if ( info->depth != 0 )
    {
        NSURL *newName =
            [info->selectedName URLByAppendingPathComponent:[fileNode filename]];

        [info->selectedName release];

        [newName retain];
        info->selectedName = newName;
    }
    
    NSRect  subBounds = *bounds;
    [self cropSubRectangle:&subBounds withInfo:info];

    SVLayoutLeaf* sub =
        [child getSelected:point withInfo:info andBounds:&subBounds];

    if ( sub == nil )
    {
        info->selectionRect = *bounds;
        return self;
    }
    else return sub;
}

- (id)initWithFileList:(NSArray*)fileList
               forNode:(SVFileTree*)t
          andTotalSize:(FileSize)totalSize
{
    self = [super initWithFile:t];
    child = [[SVLayoutTree alloc] initWithFileList:fileList
                                      andTotalSize:totalSize];
    return self;
}

- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds
{
    if ( ![self drawableWithInfo:info inBounds:bounds] )
        return;

    [info->gatherer addRectangle:bounds
                    withColor:(info->selected == fileNode)
                                ? [info->wheel getSelectionColor]
                                : [info->wheel getLevelColor]];

    [self drawNodeText:info inBounds:bounds];

    NSRect sub = *bounds;
    [self cropSubRectangle:&sub withInfo:info];
    
    [info->wheel pushColor];
    [child drawGeometry:info inBounds:&sub];
    [info->wheel popColor];
}
@end

