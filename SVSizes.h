
#import <Cocoa/Cocoa.h>

typedef struct SVSizes_t
{
    CGFloat leftMargin;
    CGFloat rightMargin;
    CGFloat topMargin;
    CGFloat bottomMargin;

    CGFloat divideLeftMargin;
    CGFloat divideRightMargin;
    CGFloat divideTopMargin;
    CGFloat divideBottomMargin;

    CGFloat textLeftMargin;
    CGFloat textTopMargin;
    CGFloat textHeight;
} SVSizes;

extern const SVSizes  blockSizes;

