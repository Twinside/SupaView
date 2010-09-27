#import "SVUnscanned.h"
#import "../LayoutTree/SVLayoutUnscanned.h"

@implementation SVUnscannedTree
- (id)init
{
    self = [super initWithFileName:@"Unscanned"
                           andSize:0];
    return self;
}

- (SVLayoutNode*)createLayoutTree
{
    return [[SVLayoutUnscanned alloc] initWithFile:self];
}
@end
