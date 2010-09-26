#import <Cocoa/Cocoa.h>
#import "SVLayoutTree.h"
#import "SVGraphViz.h"


@interface SVVolume : SVFileTree {
    // put instances variable here
    FileSize    emptySpace;
}

- (id)initWithFileName:(NSURL*)treeName;
- (SVLayoutTree*)createLayoutTree;
@end
