#import "SVLayoutTree.h"
#import "SVLayoutNode.h"
#import "SVLayoutLeaf.h"
#import "SVLayoutFolder.h"
#import "../TreeMapView/SVNarrowingState.h"


typedef enum LayoutDeleteAction_t {
    DoDelete,
    DeleteDone,
    DeleteSearch
} LayoutDeleteAction;

typedef struct DeleteRez_t
{
    LayoutDeleteAction action;
    SVLayoutNode       *newChild;
} DeleteRez;

@interface SVLayoutNode (UrlSearching)
- (void)gatherChild:(NSMutableArray*)arr;
- (DeleteRez)deleteNode:(NSArray*)urlParts
                 atPart:(int)partIdx
              andUpdate:(NSArray*)narrowState
                atDepth:(int)narrowIdx;
@end

@interface SVLayoutLeaf (UrlSearching)
- (void)gatherChild:(NSMutableArray*)arr;
- (DeleteRez)deleteNode:(NSArray*)urlParts
                 atPart:(int)partIdx
              andUpdate:(NSArray*)narrowState
                atDepth:(int)narrowIdx;
@end

@interface SVLayoutFolder (UrlSearching)
- (DeleteRez)deleteNode:(NSArray*)urlParts
                 atPart:(int)partIdx
              andUpdate:(NSArray*)narrowState
                atDepth:(int)narrowIdx;
@end

@interface SVLayoutTree (UrlSearching)
- (void)gatherChild:(NSMutableArray*)arr;
- (DeleteRez)deleteNode:(NSArray*)urlParts
                 atPart:(int)partIdx
              andUpdate:(NSArray*)narrowState
                atDepth:(int)narrowIdx;
@end

