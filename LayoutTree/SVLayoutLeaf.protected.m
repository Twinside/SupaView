#import "SVLayoutLeaf.protected.h"
#import "../SVSizes.h"
#import "../SVSizeFormatter.h"

@implementation SVLayoutLeaf (Protected)

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

@end

