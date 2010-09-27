#import "SVEmptyNode.h"
#import "../LayoutTree/SVLayoutEmptySpace.h"

@implementation SVEmptyNode
- (id)initWithFileSize:(FileSize)size
{
    self = [super initWithFileName:@"Empty space"
                           andSize:size];
    return self;
}

- (SVLayoutNode*)createLayoutTree
{
    SVLayoutNode  *layoutNode =
        [[SVLayoutEmptySpace alloc] initWithFile:self];

    return layoutNode;
}
@end

