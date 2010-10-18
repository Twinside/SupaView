#import "Layout.searching.h"
#import "../FileTree/SVFolderTree.h"

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
{
    NSString*   ourPart = [urlParts objectAtIndex:partIdx];
    if ( [ourPart isEqualToString:[fileNode filename]] )
        return makeDeleteRez( DoDelete, self );

    return makeDeleteRez( DeleteSearch, nil );
}
@end
 
@implementation SVLayoutFolder (URLSearching)
- (void)rebalance
{
    int childCount = [((SVFolderTree*)fileNode) childCount];

    // if we have only one child or less we don't have
    // anything to rebalance :]
    if ( childCount <= 1 ) return;

    NSMutableArray *arr =
        [[NSMutableArray alloc]
            initWithCapacity:childCount];

    
    [child gatherChild:arr];

    [arr sortUsingComparator:SvLayoutNodeComparer];

    SVLayoutNode    *oldChild = child;
    child = [[SVLayoutTree alloc]
                initWithFileList:arr
                    andTotalSize:[fileNode diskSize]];

    [child retain];
    [arr release];
    [oldChild release];
}

- (DeleteRez)deleteNode:(NSArray*)urlParts
                 atPart:(int)partIdx
{
    NSString*   ourPart = [urlParts objectAtIndex:partIdx];

    // we are not part of the deleted URL, return :)
    if ( ![ourPart isEqualToString:[fileNode filename]] )
        return makeDeleteRez( DeleteSearch, nil );

    // if we are the deleted something
    if ( partIdx == (int)[urlParts count] - 1 )
        return makeDeleteRez(DoDelete, self);
    
    DeleteRez sub =
        [child deleteNode:urlParts atPart:partIdx + 1];

    
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
        [self rebalance];
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

{
    DeleteRez sub =
        [left deleteNode:urlParts atPart:partIdx];

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

    sub = [right deleteNode:urlParts atPart:partIdx];

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

