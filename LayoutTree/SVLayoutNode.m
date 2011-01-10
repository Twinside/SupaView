#import "SVLayoutNode.h"
#import "../SVSizes.h"

NSComparator SvLayoutNodeComparer = (NSComparator)^(id obj1, id obj2){
        FileSize lSize = [obj1 nodeSize];
        FileSize rSize = [obj2 nodeSize];
        
        if (lSize < rSize)
            return (NSComparisonResult)NSOrderedDescending;
        
        if (lSize > rSize)
            return (NSComparisonResult)NSOrderedAscending;
        
        return (NSComparisonResult)NSOrderedSame;
    };

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

inline static
BOOL insideRect( const NSRect *r, const NSPoint *p )
{
    return (r->origin.x <= p->x)
        && (r->origin.y <= p->y)
        && (r->origin.x + r->size.width >= p->x)
        && (r->origin.y + r->size.height >= p->y);
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

- (FileSize)nodeSize { return 0; }

- (SVLayoutLeaf*)getNodeConforming:(LayoutPredicate)predicate
                          withInfo:(SVDrawInfo*)info
                         andBounds:(NSRect*)bounds
{ return nil; /* do nothing */ }

- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds
{ /* do nothing */ }

- (SVLayoutLeaf*)getNodeAtPoint:(NSPoint)point
                       withInfo:(SVDrawInfo*)info
                      andBounds:(NSRect*)bounds
{
    LayoutPredicate pred =
        ^ bool ( SVLayoutNode *node, SVDrawInfo* i, NSRect * b ){ 
            return insideRect( b, &point ) &&
                [node drawableWithInfo:i inBounds:b];
        };

    return [self getNodeConforming:pred
                          withInfo:info
                         andBounds:bounds];
}

- (SVFileTree*)fileNode { return nil; }
@end

