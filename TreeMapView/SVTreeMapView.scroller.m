#import "SVTreeMapView.scroller.h"
#import "SVTreeMapView.private.h"

static inline double clamp( double val )
{
    if (val < 0) return 0;
    if (val > 1) return 1;
    return val;
}

@implementation SVTreeMapView (ScrollerHandling)
- (void)allocateInitScroller//:(NSRect)frameRect
{
    [verticalScroller setTarget:self];
    [verticalScroller setAction:@selector(scrollVertical:)];
    [verticalScroller setArrowsPosition:NSScrollerArrowsMaxEnd];
    [verticalScroller setEnabled:YES];
    
    [horizontalScroller setTarget:self];
    [horizontalScroller setAction:@selector(scrollHorizontal:)];
    [horizontalScroller setArrowsPosition:NSScrollerArrowsMaxEnd];
    [horizontalScroller setEnabled:YES];
}

- (double)extractScrollerValue:(NSScroller*)scroll andReplace:(BOOL*)replace
{
    *replace = YES;
    switch ([scroll hitPart])
    {
    case NSScrollerIncrementLine:
        // Include code here for the case where the down arrow is pressed
        return clamp([scroll doubleValue] + 0.05);

    case NSScrollerDecrementLine:
        // Include code here for the case where the up arrow is pressed
        return clamp([scroll doubleValue] - 0.05);

    case NSScrollerDecrementPage:
        return clamp([scroll doubleValue] - 0.10);

    case NSScrollerIncrementPage:
        return clamp([scroll doubleValue] + 0.10);
        
    default:
    case NSScrollerKnob:
        *replace = NO;
        return [scroll doubleValue];
    }
    return 0.0;
}

- (void)scrollHorizontal:(id)sender
{
    BOOL    replace;
    NSRect frame = [self bounds];
    virtualSize.origin.x = [self extractScrollerValue:horizontalScroller
                                           andReplace:&replace]
                         * (frame.size.width - virtualSize.size.width);
    
    if (replace) [self updateScrollerPosition];
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (void)scrollVertical:(id)sender
{
    BOOL    replace;
    NSRect frame = [self bounds];
    virtualSize.origin.y = (1.0 - [self extractScrollerValue:verticalScroller
                                                  andReplace:&replace])
                         * (frame.size.height - virtualSize.size.height);
    
    if (replace) [self updateScrollerPosition];
    [self updateGeometry];
    [self setNeedsDisplay:YES];
}

- (void)updateScrollerPosition
{
    NSRect frame = [self bounds];
    double horizontalViewWidth =
        virtualSize.size.width / frame.size.width;

    double horizontalPos = virtualSize.origin.x
                         / (frame.size.width - virtualSize.size.width);
    [horizontalScroller setKnobProportion:horizontalViewWidth];
    [horizontalScroller setDoubleValue:horizontalPos];


    double verticalViewWidth =
        virtualSize.size.height / frame.size.height;

    double verticalPos = virtualSize.origin.y
                       / (frame.size.height - virtualSize.size.height);

    [verticalScroller setDoubleValue: 1.0 - verticalPos];
    [verticalScroller setKnobProportion:verticalViewWidth];
}
@end

