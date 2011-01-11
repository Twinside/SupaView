#import <Cocoa/Cocoa.h>
#import "../FileTree/SVFileTree.h"
#import "../LayoutTree/SVLayoutNode.h"

@interface SVNodeState : NSObject {
    @public NSURL        *url;
    @public SVFileTree   *file;
    @public SVLayoutNode *layout;
    @public NSRect       size;
}
- (id)init;
- (id)initWithUrl:(NSURL*)url
             file:(SVFileTree*)file
           layout:(SVLayoutNode*)layout
             size:(NSRect)s;
- (void)dealloc;
@end

