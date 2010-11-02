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
    [horizontalScroller
        setDoubleValue: virtualSize.origin.x
                      / frame.size.width];

    [horizontalScroller
        setKnobProportion: virtualSize.size.width
                         / frame.size.width];

    [verticalScroller
        setDoubleValue: 1.0 - virtualSize.origin.y
                              / frame.size.height];

    [verticalScroller
        setKnobProportion: virtualSize.size.height
                         / frame.size.height];
}
@end

