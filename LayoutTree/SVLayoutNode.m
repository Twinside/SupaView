#import "SVLayoutNode.h"
#import "../SVSizes.h"

inline static
BOOL intersect( const NSRect *a, const NSRect *b )
{
    CGFloat aRight = a->origin.x + a->size.width;
    CGFloat aTop = a->origin.y + a->size.height;
    
    CGFloat bRight = b->origin.x + b->size.width;
    CGFloat bTop = b->origin.y + b->size.height;
    
    return (a->origin.y <= bTop)
        && (a->origin.x <= bRight)
        && (aRight >= b->origin.x)
        && (aTop >= b->origin.y);
}

@implementation SVLayoutNode
- (BOOL)drawableWithInfo:(SVDrawInfo*)info
                inBounds:(NSRect*)bounds
{
    BOOL bigEnough =
         bounds->size.width >= blockSizes.minBoxSizeWidth * info->minimumWidth
      && bounds->size.height >= blockSizes.minBoxSizeHeight * info->minimumHeight;

    return intersect(bounds, info->limit)
        && bigEnough;
}

- (SVLayoutLeaf*)getSelected:(NSPoint)point
                    withInfo:(SVDrawInfo*)info
                   andBounds:(NSRect*)bounds
{ return nil; /* do nothing */ }

- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds
{ /* do nothing */ }
@end

