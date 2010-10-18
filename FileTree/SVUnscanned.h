#import "SVDynamicFileTree.h"

@interface SVUnscannedTree : SVDynamicFileTree {
}
- (id)init;
- (SVLayoutNode*)createLayoutTree:(int)maxDepth atDepth:(int)depth;
@end
