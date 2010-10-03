#import <Cocoa/Cocoa.h>
#import "SVTreeMapView.animate.h"

@interface AnimationPerFrame : NSAnimation {
    SVTreeMapView       *animatedView;
    NSRect              initialRect;
    NSRect              endRect;
}

- (id)initWithView:(SVTreeMapView*)view 
            toRect:(NSRect)r
       andDuration:(CGFloat)duration;
- (void)setCurrentProgress:(NSAnimationProgress)progress;
@end

