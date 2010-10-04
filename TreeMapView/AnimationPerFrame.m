#import "AnimationPerFrame.h"

static inline float lerp( float begin, float end, float zeroToOne )
    { return begin + (end - begin) * zeroToOne; }

static inline NSRect lerpRect( NSRect a, NSRect b, float zeroToOne )
{
    NSRect ret =
        { .origin = { .x = lerp( a.origin.x, b.origin.x, zeroToOne )
                    , .y = lerp( a.origin.y, b.origin.y, zeroToOne ) }

        , .size = { .width = lerp( a.size.width, b.size.width, zeroToOne )
                  , .height = lerp( a.size.height, b.size.height, zeroToOne ) }
        };
    return ret;
}

@implementation AnimationPerFrame

- (id)initWithView:(SVTreeMapView*)view 
          fromRect:(NSRect)begin
            toRect:(NSRect)r
       andDuration:(CGFloat)duration
{
    self = [super initWithDuration:duration
                    animationCurve:NSAnimationEaseOut];
    
    animatedView = view;
    initialRect = begin;
    endRect = r;
    [self setFrameRate:0.0f];
    [self setAnimationBlockingMode:NSAnimationNonblocking];
    [self setDelegate:view];
    return self;
}

- (void)setCurrentProgress:(NSAnimationProgress)progress
{
    [animatedView setVirtualSize:lerpRect( initialRect
                                         , endRect
                                         , progress )];
    [super setCurrentProgress:progress];
}
@end

