
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
    SelectionTouched,
    SelectionNotHere,
    SelectionOperationDone
} SVSelectionAction;

@interface SVLayoutNode (KeyboardNavigation)
- (SVSelectionAction)moveSelection:(SVDrawInfo*)nfo
                       inDirection:(SVSelectionDirection)dir
                      withinBounds:(NSRect)bounds;

- (void)selectFirst:(BOOL)isFirst
           withInfo:(SVDrawInfo*)nfo
           inBounds:(NSRect)bounds;
@end

@interface SVLayoutLeaf (KeyboardNavigation)
- (SVSelectionAction)moveSelection:(SVDrawInfo*)nfo
                       inDirection:(SVSelectionDirection)dir
                      withinBounds:(NSRect)bounds;

- (void)selectFirst:(BOOL)isFirst
           withInfo:(SVDrawInfo*)nfo
           inBounds:(NSRect)bounds;
@end

@interface SVLayoutTree (KeyboardNavigation)
- (SVSelectionAction)moveSelection:(SVDrawInfo*)nfo
                       inDirection:(SVSelectionDirection)dir
                      withinBounds:(NSRect)bounds;

- (void)selectFirst:(BOOL)isFirst
           withInfo:(SVDrawInfo*)nfo
           inBounds:(NSRect)bounds;
@end

