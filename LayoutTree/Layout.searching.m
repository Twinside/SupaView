#import "Layout.searching.h"

inline static
DeleteRez makeDeleteRez( LayoutDeleteAction a, SVLayoutNode *c )
{
    DeleteRez ret = { .action = a, .newChild = c };
    return ret;
}

@implementation SVLayoutNode (URLSearching)
- (void)gatherChild:(NSMutableArray*)arr {}
@end

@implementation SVLayoutLeaf (URLSearching)
- (void)gatherChild:(NSMutableArray*)arr
    { [arr addObject:self]; }

- (DeleteRez)deleteNode:(NSArray*)urlParts
                     atPart:(int)partIdx
                  andUpdate:(NSArray*)narrowState
                    atDepth:(int)narrowIdx
{
    NSString*   ourPart = [urlParts objectAtIndex:partIdx];
    if ( [ourPart isEqualToString:[fileNode filename]] )
        return makeDeleteRez( DoDelete, self );

    return makeDeleteRez( DeleteSearch, nil );
}
@end
 
@implementation SVLayoutFolder (URLSearching)
- (DeleteRez)deleteNode:(NSArray*)urlParts
                 atPart:(int)partIdx
              andUpdate:(NSArray*)narrowState
                atDepth:(int)narrowIdx
{
    NSString*   ourPart = [urlParts objectAtIndex:partIdx];

    // we are not part of the deleted URL, return :)
    if ( ![ourPart isEqualToString:[fileNode filename]] )
        return makeDeleteRez( DeleteSearch, nil );

    DeleteRez sub =
        [child deleteNode:urlParts atPart:partIdx + 1
                andUpdate:narrowState atDepth:narrowIdx];

    
    switch ( sub.action )
    {
    // can happen if we delete the direct children which
    // is just a child
    case DoDelete:
        [child release];
        child = nil;
        break;

    case DeleteDone:
        [sub.newChild retain];
        [child release];
        child = sub.newChild;
            // rebalance
        break;

    case DeleteSearch:
        // should never happen
        assert( false );
        break;
    }

    return makeDeleteRez( DeleteDone, self );
}
@end

@implementation SVLayoutTree (URLSearching)
- (void)gatherChild:(NSMutableArray*)arr
{
    [left gatherChild:arr];
    [right gatherChild:arr];
}

- (DeleteRez)deleteNode:(NSArray*)urlParts
                 atPart:(int)partIdx
              andUpdate:(NSArray*)narrowState
                atDepth:(int)narrowIdx

{
    DeleteRez sub =
        [left deleteNode:urlParts
                  atPart:partIdx
               andUpdate:narrowState
                 atDepth:narrowIdx];

    switch (sub.action)
    {
    case DoDelete:
        [left release];
        left = nil;
        return makeDeleteRez( DeleteDone, self );
        
    case DeleteDone:
        [sub.newChild retain];
        [left release];
        left = sub.newChild;
        return makeDeleteRez( DeleteDone, self );

    case DeleteSearch:
        /* we just continue the search */
        break;
    }

    sub = [right deleteNode:urlParts
                     atPart:partIdx
                  andUpdate:narrowState
                    atDepth:narrowIdx];

    switch (sub.action)
    {
    case DoDelete:
        [right release];
        right = nil;
        return makeDeleteRez( DeleteDone, self );
        
    case DeleteDone:
        [sub.newChild retain];
        [right release];
        right = sub.newChild;
        return makeDeleteRez( DeleteDone, self );

    // just transmit the message
    case DeleteSearch:
        break;
    }

    return makeDeleteRez( DeleteSearch, nil );

}
@end

