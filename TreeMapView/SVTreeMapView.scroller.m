#import "SVTreeMapView.scroller.h"

@implementation SVTreeMapView (ScrollerHandling)
- (void)allocateInitScroller:(NSRect)frameRect
{
    /// Scroller declaration
    const int scrollSize = [NSScroller scrollerWidth];
    NSRect verticalScrollRect = frameRect;
    verticalScrollRect.origin.x += verticalScrollRect.size.width - scrollSize;
    verticalScrollRect.size.width = scrollSize;

    verticalScroller =
        [[NSScroller alloc] initWithFrame:verticalScrollRect];
    [verticalScroller
        setAutoresizingMask:NSViewMinXMargin | NSViewHeightSizable];
    [verticalScroller setArrowsPosition:NSScrollerArrowsMaxEnd];
    [verticalScroller setTarget:self];
    [verticalScroller setArrowsPosition:NSScrollerArrowsMaxEnd];
    [verticalScroller setEnabled:YES];
    [self addSubview:verticalScroller];

    NSRect horizontalScrollRect = frameRect;
    verticalScrollRect.size.height = scrollSize;
    horizontalScroller =
        [[NSScroller alloc] initWithFrame:horizontalScrollRect];
    [horizontalScroller
        setAutoresizingMask:NSViewMaxYMargin | NSViewWidthSizable];
    [horizontalScroller setTarget:self];
    [horizontalScroller setArrowsPosition:NSScrollerArrowsMaxEnd];
    [horizontalScroller setEnabled:YES];
    [self addSubview:horizontalScroller];
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

