
#import "SVLayoutKeyNavigation.h"

@implementation SVLayoutNode (KeyboardNavigation)
- (SVSelectionAction)moveSelection:(SVDrawInfo*)nfo
                          inDirection:(SVSelectionDirection)dir
                         withinBounds:(NSRect)bounds
    { return SelectionNotHere; }

- (void)selectFirst:(BOOL)isFirst
           withInfo:(SVDrawInfo*)nfo
           inBounds:(NSRect)bounds {}
@end

@implementation SVLayoutLeaf (KeyboardNavigation)
- (void)selectFirst:(BOOL)isFirst
           withInfo:(SVDrawInfo*)nfo
           inBounds:(NSRect)bounds
{
    // ok we just select ourselves.
    nfo->selection.node = fileNode;
    nfo->selection.rect = bounds;
    nfo->selection.isFile = YES;
    nfo->selection.layoutNode = self;

    NSURL   *newUrl =
        [nfo->selection.name
                URLByAppendingPathComponent:[fileNode filename]];

    [nfo->selection.name release];
    [newUrl retain];
    nfo->selection.name = newUrl;
}

- (SVSelectionAction)moveSelection:(SVDrawInfo*)nfo
                          inDirection:(SVSelectionDirection)dir
                         withinBounds:(NSRect)bounds
{
    // we are selected, we must escape the selection
    // so we let upper layer handle it.
    if ( nfo->selection.node == fileNode )
        return SelectionTouched;

    return SelectionNotHere;
}
@end

@implementation SVLayoutFolder (KeyboardNavigation)
- (void)selectFirst:(BOOL)isFirst
           withInfo:(SVDrawInfo*)nfo
           inBounds:(NSRect)bounds
{
    [super selectFirst:isFirst withInfo:nfo inBounds:bounds];
    nfo->selection.isFile = NO;
}

- (SVSelectionAction)moveSelection:(SVDrawInfo*)nfo
                          inDirection:(SVSelectionDirection)dir
                         withinBounds:(NSRect)bounds
{
    // we are selected, we must escape the selection
    // so we let upper layer handle it.
    if ( nfo->selection.node == fileNode )
        return SelectionTouched;

    NSRect subRect = bounds;
    [self cropSubRectangle:&subRect withInfo:nfo];

    // clip bounds !
    return [child moveSelection:nfo
                    inDirection:dir
                   withinBounds:bounds];
}
@end

@implementation SVLayoutTree (KeyboardNavigation)
- (void)selectFirst:(BOOL)isFirst
           withInfo:(SVDrawInfo*)nfo
           inBounds:(NSRect)bounds
{
    NSRect leftBounds = bounds;
    NSRect rightBounds = bounds;
    [self splitRectangles:&leftBounds and:&rightBounds];

    if ( isFirst )
    {
        orientation &= ~SelectionMask;
        orientation |= SelectionAtLeft;
        return [left selectFirst:isFirst withInfo:nfo inBounds:leftBounds];
    }
    else
    {
        orientation &= ~SelectionMask;
        orientation |= SelectionAtRight;
        return [right selectFirst:isFirst withInfo:nfo inBounds:rightBounds];
    }
}

- (SVSelectionAction)moveSelection:(SVDrawInfo*)nfo
                   inDirection:(SVSelectionDirection)dir
                  withinBounds:(NSRect)bounds
{
    LayoutKind selecDir = orientation & SelectionMask;
    LayoutKind layoutDir = orientation & LayoutMask;
    LayoutKind inverseSelec;

    NSRect leftBounds = bounds;
    NSRect rightBounds = bounds;
    [self splitRectangles:&leftBounds and:&rightBounds];


    // aliases for selected and "other"
    SVLayoutNode    *toScann, *other;
    NSRect          *scanBounds, *otherBounds;
    BOOL            mustJump;

    if ( selecDir == SelectionAtLeft )
    {
        toScann = left;
        scanBounds = &leftBounds;
        other = right;
        otherBounds = &rightBounds;
        inverseSelec = SelectionAtRight;
        
        if (layoutDir == LayoutVertical)
            mustJump = dir != DirectionUp;
        else
            mustJump = dir != DirectionRight;
    }
    else
    {
        toScann = right;
        scanBounds = &rightBounds;
        other = left;
        otherBounds = &leftBounds;
        inverseSelec = SelectionAtLeft;

        if (layoutDir == LayoutVertical)
            mustJump = dir != DirectionDown;
        else
            mustJump = dir != DirectionLeft;
    }

    SVSelectionAction subAction =
        [toScann moveSelection:nfo inDirection:dir
                                  withinBounds:*scanBounds];

    switch (subAction)
    {
    case SelectionTouched:
        // we can't handle it, let the upper
        // node do it for us.
        if (mustJump)
            return SelectionTouched;

        [other selectFirst:dir == DirectionRight || dir == DirectionUp
                withInfo:nfo
                inBounds:*otherBounds];

        orientation &= ~SelectionMask;
        orientation |= inverseSelec;

        return SelectionOperationDone;

    case SelectionOperationDone:
        return SelectionOperationDone;

    case SelectionNotHere: return SelectionNotHere;
    }

    /*
    subAction = [other moveSelection:nfo inDirection:dir
                        withinBounds:*otherBounds];

    switch ( subAction )
    {
    case SelectionOperationDone: return SelectionOperationDone;
    case SelectionNotHere:       return SelectionNotHere;
    case SelectionTouched :      break;
    }

    return SelectionOperationDone;
    // */
    return SelectionNotHere;
}
@end

