#import "SVUnscanned.h"
#import "../LayoutTree/SVLayoutUnscanned.h"

@implementation SVUnscannedTree
- (id)init
{
    NSString *msgString =
        NSLocalizedStringFromTable(@"UnscannedSpace", @"Custom", @"A comment");
    
    self = [super initWithFileName:msgString
                           andSize:0];
    return self;
}

- (SVLayoutNode*)createLayoutTree
{
    return [[SVLayoutUnscanned alloc] initWithFile:self];
}
@end
