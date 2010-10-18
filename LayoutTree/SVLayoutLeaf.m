#import "SVLayoutLeaf.h"
#import "SVLayoutLeaf.protected.h"

#import "../SVSizes.h"
#import "../SVColorWheel.h"
#import "../SVSizeFormatter.h"

@implementation SVLayoutLeaf
- (id)initWithFile:(SVFileTree *)file
{
    self = [super init];
    fileNode = file;
    return self;
}

- (BOOL)textDrawableInBounds:(NSRect*)bounds andInfo:(SVDrawInfo*)info {
    return bounds->size.height >= blockSizes.textHeight * info->minimumHeight
        && bounds->size.width >= blockSizes.textMinimumWidth * info->minimumHeight;
}

- (SVLayoutLeaf*)getSelected:(NSPoint)point
                    withInfo:(SVDrawInfo*)info
                   andBounds:(NSRect*)bounds
{
    NSURL *newName =
        [info->selection.name URLByAppendingPathComponent:[fileNode filename]];

    [info->selection.name release];

    [newName retain];
    info->selection.name = newName;

    info->selection.isFile = TRUE;
    info->selection.rect = *bounds;

    return self;
}

- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds
{
    [info->gatherer addRectangle:bounds
                    withColor:(info->selection.node == fileNode)
                                ? [info->wheel getSelectionColor]
                                : [info->wheel getLevelColor]];

    [self drawFileName:info inBounds:bounds];
}

- (SVFileTree*)fileNode { return fileNode; }
- (FileSize)nodeSize { return [fileNode fileSize]; }
@end
