//
//  GeometryGatherer.m
//  SupaView
//
//  Created by Vincent Berthoux on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVGeometryGatherer.h"

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

- (id)initWithRectCount:(int)count
{
    self = [super init];
    
    maxRectangleCount = count;
    rects = (NSRect*)malloc( sizeof( NSRect ) * count );
    colors = (NSColor**)malloc( sizeof( NSColor* ) * count );
    rectangleWrite = 0;

    textWrite = [[NSMutableArray alloc] initWithCapacity:50];
    return self;
}

- (void)dealloc
{
    free( rects );
    free( colors );
    rects = nil;
    colors = nil;
    [textWrite release];
    [super dealloc];
}

- (void)addRectangle:(NSRect*)r
           withColor:(NSColor*)c
{
    assert( rectangleWrite < maxRectangleCount );
    rects[ rectangleWrite ] = *r;
    colors[ rectangleWrite++ ] = c;
}


- (void)addText:(NSString*)str inRect:(NSRect*)rect
{
    SVStringDraw    *s =
        [[SVStringDraw alloc] initWithString:str
                                     atPlace:rect];

    [textWrite addObject:s];
    [s release];
}

- (void)starGathering
{
    rectangleWrite = 0;
    [textWrite removeAllObjects];
}

- (size_t)rectangleCount
    { return rectangleWrite; }

- (NSRect*)getRectangles
    { return rects; }

- (NSColor**)getColors
    { return colors; }

- (NSMutableArray*)getText
    { return textWrite; };
@end

