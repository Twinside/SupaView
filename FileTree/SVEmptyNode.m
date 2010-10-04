#import "SVEmptyNode.h"
#import "../LayoutTree/SVLayoutEmptySpace.h"

@implementation SVEmptyNode
- (id)initWithFileSize:(FileSize)size
{
    NSString *msgString =
        NSLocalizedStringFromTable(@"EmptySpace", @"Custom", @"A comment");

    self = [super initWithFileName:msgString
                           andSize:size];
    return self;
}

- (SVLayoutNode*)createLayoutTree
{
    SVLayoutNode  *layoutNode =
        [[SVLayoutEmptySpace alloc] initWithFile:self];

    return [layoutNode autorelease];
}
@end

