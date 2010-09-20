//
//  GeometryGatherer.m
//  SupaView
//
//  Created by Vincent Berthoux on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVGeometryGatherer.h"
#import "SVUtils.h"

@implementation SVStringDraw
- initWithString:(NSString*)s atPlace:(NSRect*)position
{
    self = [super init];
    str = s;
    [str retain];
    pos = *position;
    return self;
}
- (void)dealloc
{
    [str release];
    [super dealloc];
}

- (NSString*)text { return str; }
- (NSRect*)position { return &pos; }

@end

@implementation SVGeometryGatherer

- (id)initWithRectCount:(int)count {
    self = [super init];
    
    maxRectangleCount = count;
    rects = (NSRect*)malloc( sizeof( NSRect ) * count );
    colors = (NSColor**)malloc( sizeof( NSColor* ) * count );
    rectangleWrite = 0;
    collecting = false;

    textWrite = [[NSMutableArray alloc] initWithCapacity:50];
    return self;
}

- (void)dealloc {
    free( rects );
    free( colors );
    rects = nil;
    colors = nil;
    [textWrite release];
    [super dealloc];
}

- (void) scalePoint:(NSPoint*)p {
    p->x = p->x * widthScale + translateX;
    p->y = p->y * heightScale + translateY;
}

- (void) unscalePoint:(NSPoint*)p {
    p->x = (p->x - translateX) / widthScale;
    p->y = (p->y - translateY) / heightScale;
}

- (void)scaleRectangle:(NSRect*)r {
    r->size.width *= widthScale;
    r->size.height *= heightScale;

    [self scalePoint:&r->origin];
}

- (void)addRectangle:(NSRect*)r
           withColor:(NSColor*)c {
    assert( collecting );
    assert( rectangleWrite < maxRectangleCount );
    // rects[ rectangleWrite ] = *r;
    colors[ rectangleWrite ] = c;

    NSRect* wroteRect = &rects[rectangleWrite];

    // take the biggest, if frame is bigger
    wroteRect->origin.x = maxi( frameRect.origin.x, r->origin.x );
    wroteRect->origin.y = maxi( frameRect.origin.y, r->origin.y );

    CGFloat widthLoss = r->origin.x - wroteRect->origin.x;
    CGFloat heightLoss = r->origin.y - wroteRect->origin.y;
    wroteRect->size.width = mini( r->size.width - widthLoss
                                , frameRect.size.width );
    wroteRect->size.height = mini( r->size.height - heightLoss 
                                 , frameRect.size.height );

    // cull-out degenerate triangles
    if (wroteRect->size.width > 0 && wroteRect->size.height > 0)
        rectangleWrite++;

    [self scaleRectangle:wroteRect];
}


- (void)addText:(NSString*)str inRect:(NSRect*)rect {
    assert( collecting );

    NSRect  tempRect = *rect;
    [self scalePoint:&tempRect.origin];
    tempRect.size.width *= widthScale;

    SVStringDraw    *s =
        [[SVStringDraw alloc] initWithString:str
                                     atPlace:&tempRect];

    [textWrite addObject:s];
    [s release];
}

- (void)startGathering:(NSRect*)frameView
              inBounds:(NSRect*)bounds {
    assert( !collecting );
    rectangleWrite = 0;
    frameRect = *frameView;

    widthScale = frameRect.size.width / bounds->size.width;
    heightScale = frameRect.size.height / bounds->size.height;
    translateX = - (bounds->origin.x * widthScale);
    translateY = - (bounds->origin.y * heightScale);

    [textWrite removeAllObjects];
    collecting = true;
}

- (CGFloat)virtualPixelWidthSize {
    // assert( collecting );   
    return 1.0f / widthScale;
}

- (CGFloat)virtualPixelHeightSize {
    // assert( collecting );   
    return 1.0f / heightScale;
}

- (void)stopGathering {
    assert( collecting );
    collecting = false;
}

- (size_t)rectangleCount {
    assert( !collecting );
    return rectangleWrite;
}

- (NSRect*)getRectangles {
    assert( !collecting );
    return rects;
}

- (NSColor**)getColors {
    assert( !collecting );
    return colors;
}

- (NSMutableArray*)getText {
    assert( !collecting );
    return textWrite;
};
@end

