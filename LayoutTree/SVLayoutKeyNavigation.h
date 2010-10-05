
#import <Cocoa/Cocoa.h>
#import "SVLayoutLeaf.h"
#import "SVLayoutTree.h"
#import "SVLayoutFolder.h"

/**
 * Constants used for keyboard navigation
 */
typedef enum SVSelectionDirection_t
{
    DirectionUp = 0,
    DirectionDown = 1,
    DirectionLeft = 2,
    DirectionRight = 3,
    LastDirection = 4,
    DoneDirectionChange = 5,
} SVSelectionDirection;

typedef enum SVSelectionAction_t
{
    SelectionAsk,
    SelectionSet
} SVSelectionAction;

@interface SVLayoutNode (KeyboardNavigation)
- (SVLayoutLeaf*)moveSelection:(SVDrawInfo*)nfo
                   inDirection:(SVSelectionDirection)dir
                  withinBounds:(NSRect)bounds;

- (SVLayoutLeaf*)selectFirst:(BOOL)isFirst
                    withInfo:(SVDrawInfo*)nfo
                    inBounds:(NSRect)bounds;
@end

@interface SVLayoutLeaf (KeyboardNavigation)
- (SVLayoutLeaf*)moveSelection:(SVDrawInfo*)nfo
                   inDirection:(SVSelectionDirection)dir
                  withinBounds:(NSRect)bounds;

- (SVLayoutLeaf*)selectFirst:(BOOL)isFirst
                    withInfo:(SVDrawInfo*)nfo
                    inBounds:(NSRect)bounds;
@end

@interface SVLayoutFolder (KeyboardNavigation)
- (SVLayoutLeaf*)moveSelection:(SVDrawInfo*)nfo
                   inDirection:(SVSelectionDirection)dir
                  withinBounds:(NSRect)bounds;
@end

@interface SVLayoutTree (KeyboardNavigation)
- (SVLayoutLeaf*)moveSelection:(SVDrawInfo*)nfo
                   inDirection:(SVSelectionDirection)dir
                  withinBounds:(NSRect)bounds;

- (SVLayoutLeaf*)selectFirst:(BOOL)isFirst
                    withInfo:(SVDrawInfo*)nfo
                    inBounds:(NSRect)bounds;
@end

