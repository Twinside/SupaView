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
}
- (id)initWithNode:(SVLayoutNode*)n andURL:(NSURL*)url;
- (SVLayoutNode*)node;
- (NSURL*)url;
- (void)dealloc;
@end

