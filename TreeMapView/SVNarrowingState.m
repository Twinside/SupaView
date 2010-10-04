#import "SVNarrowingState.h"

@implementation SVNarrowingState
- (id)initWithNode:(SVLayoutNode*)n
            andURL:(NSURL*)iURL
            inRect:(NSRect*)r
{
    self = [super init];

    node = n;
    url = iURL;
    prevRect = *r;

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
- (NSRect)rect { return prevRect; }
@end

