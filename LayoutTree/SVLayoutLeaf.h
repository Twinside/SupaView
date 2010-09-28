#import "Definitions.h"
#import <Cocoa/Cocoa.h>
#import "SVLayoutNode.h"

@interface SVLayoutLeaf : SVLayoutNode {
    SVFileTree    *fileNode;
}

- (id)initWithFile:(SVFileTree*)file;

- (BOOL)textDrawableInBounds:(NSRect*)bounds
                     andInfo:(SVDrawInfo*)info;

- (SVLayoutLeaf*)getSelected:(NSPoint)point
                    withInfo:(SVDrawInfo*)info
                   andBounds:(NSRect*)bounds;

- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds;

- (SVFileTree*)fileNode;
@end
