#import "SVLayoutLeaf.h"
#import "../SVSizes.h"
#import "../SVColorWheel.h"
#import "../SVSizeFormatter.h"

@implementation SVLayoutLeaf
- (id)initWithFile:(SVFileTree *)file
{
    self = [super init];
    fileNode = file;
    return self;
}

- (BOOL)textDrawableInBounds:(NSRect*)bounds andInfo:(SVDrawInfo*)info {
    return bounds->size.height >= blockSizes.textHeight * info->minimumHeight
        && bounds->size.width >= blockSizes.textMinimumWidth * info->minimumHeight;
}

- (SVLayoutLeaf*)getSelected:(NSPoint)point
                    withInfo:(SVDrawInfo*)info
                   andBounds:(NSRect*)bounds
{
    NSURL *newName =
        [info->selectedName URLByAppendingPathComponent:[fileNode filename]];

    [info->selectedName release];

    [newName retain];
    info->selectedName = newName;

    info->selectedIsFile = TRUE;

    return self;
}

- (void)drawFileName:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds
{
    
    NSRect textPos = *bounds;

    if ( ![self textDrawableInBounds:bounds
                             andInfo:info] )
        return;

    textPos.origin.x += blockSizes.textLeftMargin * info->minimumWidth;
    textPos.origin.y += (blockSizes.bottomMargin + 1) * info->minimumHeight;
    textPos.size.height =
        textPos.size.height / info->minimumHeight
            - (blockSizes.textTopMargin + blockSizes.bottomMargin);
                

    if ( textPos.size.width > (blockSizes.fileSizeMinDisplay
                               + blockSizes.textMinimumWidth)* info->minimumWidth )
    {
        NSString *sizeString = 
            [[SVSizeFormatter sharedInstance] formatSize:[fileNode diskSize]];

        CGFloat sizeDisplaySize = ([info->gatherer evaluateStringWidth:sizeString]
                                    + blockSizes.textLeftMargin)
                                * info->minimumWidth;

        textPos.size.width -= sizeDisplaySize;
        [info->gatherer addText:[fileNode filename]
                         inRect:&textPos];

        // update to put size information
        textPos.origin.x += textPos.size.width;

        [info->gatherer addText:[[SVSizeFormatter sharedInstance] formatSize:[fileNode diskSize]]
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
    [info->gatherer addRectangle:bounds
                    withColor:(info->selected == fileNode)
                                ? [info->wheel getSelectionColor]
                                : [info->wheel getLevelColor]];

    [self drawFileName:info inBounds:bounds];
}

- (SVFileTree*)fileNode { return fileNode; }
@end
