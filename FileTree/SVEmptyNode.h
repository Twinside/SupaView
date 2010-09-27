#import "SVFileTree.h"

@interface SVEmptyNode : SVFileTree {
}
- (id)initWithFileSize:(FileSize)size;
- (SVLayoutNode*)createLayoutTree;
@end
