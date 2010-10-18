
#import <Cocoa/Cocoa.h>

typedef struct SVSizes_t
{
    CGFloat leftMargin;
    CGFloat rightMargin;
    CGFloat topMargin;
    CGFloat bottomMargin;

    CGFloat minBoxSizeWidth;
    CGFloat minBoxSizeHeight;

    CGFloat textLeftMargin;
    CGFloat textTopMargin;
    CGFloat textHeight;
    CGFloat textMinimumWidth;

    CGFloat fileSizeMinDisplay;
    CGFloat fileSizeWidth;

    int     updateMaxDepth;
    int     fullViewMaxDepth;
} SVSizes;

extern const SVSizes  blockSizes;

