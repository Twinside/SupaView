//
//
//
#import <Cocoa/Cocoa.h>

@class SVLayoutNode;

/**
 * Store the state when we narrow the tree map view.
 * We must keep track of the root node and it's
 * associated URL.
 */
@interface SVNarrowingState : NSObject {
    SVLayoutNode    *node;
    NSURL           *url;
    NSRect          prevRect;
}
- (id)initWithNode:(SVLayoutNode*)n
            andURL:(NSURL*)url
            inRect:(NSRect*)r;

- (SVLayoutNode*)node;
- (NSURL*)url;
- (void)dealloc;
@end

