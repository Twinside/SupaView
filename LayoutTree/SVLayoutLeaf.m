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
        [info->selectedName URLByAppendingPathComponent:[fileNode filename]];

    [info->selectedName release];

    [newName retain];
    info->selectedName = newName;

    info->selectedIsFile = TRUE;
    info->selectionRect = *bounds;

    return self;
}

- (void)drawGeometry:(SVDrawInfo*)info
            inBounds:(NSRect*)bounds
{
    [info->gatherer addRectangle:bounds
                    withColor:(info->selected == fileNode)
                                ? [info->wheel getSelectionColor]
                                : [info->wheel getLevelColor]];

    [self drawFileName:info inBounds:bounds];
}

- (SVFileTree*)fileNode { return fileNode; }
@end
