#import "SVNodeState.h"

@implementation SVNodeState
- (id)init
{
    self = [super init];
    url = nil;
    file = nil;
    layout = nil;
    return self;
}

- (id)initWithUrl:(NSURL*)nurl
             file:(SVFileTree*)nfile
           layout:(SVLayoutNode*)nlayout
             size:(NSRect)s
{
    self = [super init];
    url = [nurl retain];
    file = [nfile retain];
    layout = [nlayout retain];
    return self;
}

- (void)dealloc
{
    [url release];
    [file release];
    [layout release];
}
@end

