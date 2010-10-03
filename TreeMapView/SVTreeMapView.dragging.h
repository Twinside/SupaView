#import "SVTreeMapView.h"

@interface SVTreeMapView (Dragging)
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
- (void)draggingEnded:(id<NSDraggingInfo>)sender;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
- (void)drawDropStatus:(NSRect)dirtyRect;
@end

