#import "SVNarrowingState.h"

@implementation SVNarrowingState
- (id)initWithNode:(SVLayoutNode*)n andURL:(NSURL*)iURL
{
    self = [super init];

    node = n;
    url = iURL;

    [node retain];
    [url retain];

    return self;
}

- (void)dealloc
{
    [node release];
    [url release];
    [super dealloc];
}

- (SVLayoutNode*)node { return node; }
- (NSURL*)url { return url; }
@end

