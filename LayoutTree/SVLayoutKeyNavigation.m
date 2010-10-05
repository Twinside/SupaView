
#import "SVLayoutKeyNavigation.h"

@implementation SVLayoutNode (KeyboardNavigation)
- (SVLayoutLeaf*)moveSelection:(SVDrawInfo*)nfo
                          inDirection:(SVSelectionDirection)dir
                         withinBounds:(NSRect)bounds
    { return nil; }

- (SVLayoutLeaf*)selectFirst:(BOOL)isFirst
                           withInfo:(SVDrawInfo*)nfo
                           inBounds:(NSRect)bounds
    { return nil; }
@end

@implementation SVLayoutLeaf (KeyboardNavigation)
- (SVLayoutLeaf*)selectFirst:(BOOL)isFirst
                           withInfo:(SVDrawInfo*)nfo
                           inBounds:(NSRect)bounds
{
    // ok we just select ourselves.
    nfo->selection.node = fileNode;
    nfo->selection.rect = bounds;
    nfo->selection.isFile = TRUE;

    NSURL   *newUrl =
        [nfo->selection.name
                URLByAppendingPathComponent:[fileNode filename]];

    [nfo->selection.name release];
    [newUrl retain];
    nfo->selection.name = newUrl;

    return self;
}

- (SVLayoutLeaf*)moveSelection:(SVDrawInfo*)nfo
                          inDirection:(SVSelectionDirection)dir
                         withinBounds:(NSRect)bounds
{
    // we are selected, we must escape the selection
    // so we let upper layer handle it.
    if ( nfo->selection.node == fileNode )
        return nil;

    // Otherwise, yay, we gained the right to be selected :)
    return [self selectFirst:TRUE withInfo:nfo inBounds:bounds];
}
@end

@implementation SVLayoutFolder (KeyboardNavigation)
- (SVLayoutLeaf*)moveSelection:(SVDrawInfo*)nfo
                          inDirection:(SVSelectionDirection)dir
                         withinBounds:(NSRect)bounds
{
    // we are currently selected, rules are a little bit
    // different. If we don't want to digg into the
    // folder, we return
    if ( nfo->selection.node == fileNode
      && dir != DirectionDown )
            return nil;

    NSRect subBound = bounds;
    [self cropSubRectangle:&subBound withInfo:nfo];
    
    SVLayoutLeaf *childSelection =
        [child moveSelection:nfo
                 inDirection:dir
                withinBounds:subBound];

    // the children was not able to move,
    // so by layout, we must be selected
    if ( childSelection == nil )
        return [self selectFirst:TRUE withInfo:nfo
                        inBounds:bounds];
    return childSelection;
}
@end

@implementation SVLayoutTree (KeyboardNavigation)
- (SVLayoutLeaf*)selectFirst:(BOOL)isFirst
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

- (SVLayoutLeaf*)moveSelection:(SVDrawInfo*)nfo
                   inDirection:(SVSelectionDirection)dir
                  withinBounds:(NSRect)bounds
{
    LayoutKind selecDir = orientation & SelectionMask;

    NSRect leftBounds = bounds;
    NSRect rightBounds = bounds;
    [self splitRectangles:&leftBounds and:&rightBounds];


    // aliases for selected and "other"
    SVLayoutNode    *toScann, *other;
    NSRect          *scanBounds, *otherBounds;

    if ( selecDir == SelectionAtLeft )
    {
        toScann = left;
        scanBounds = &leftBounds;
        other = right;
        otherBounds = &rightBounds;
    }
    else
    {
        toScann = right;
        scanBounds = &rightBounds;
        other = left;
        otherBounds = &leftBounds;
    }

    SVLayoutLeaf *subNode =
        [toScann moveSelection:nfo inDirection:dir
                                  withinBounds:*scanBounds];

    if ( subNode == nil )
    {
        // easy, select the first other subchild, in the
        // oposite direction, if we want to move right,
        // we want it's first left child :)
        return [other selectFirst:dir == DirectionRight || dir == DirectionUp
                         withInfo:nfo
                         inBounds:*otherBounds];
    }
    else return subNode;
}
@end

