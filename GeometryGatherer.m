//
//  GeometryGatherer.m
//  SupaView
//
//  Created by Vincent Berthoux on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GeometryGatherer.h"


@implementation GeometryGatherer

- (id)initWithRectCount:(int)count
{
    self = [super init];
    
    maxRectangleCount = count;
    rects = (NSRect*)malloc( sizeof( NSRect ) * count );
    colors = (NSColor**)malloc( sizeof( NSColor* ) * count );
    rectangleWrite = 0;
    return self;
}

- (void)dealloc
{
    free( rects );
    free( colors );
    rects = nil;
    colors = nil;
    [super dealloc];
}

- (void)addRectangle:(NSRect*)r
           withColor:(NSColor*)c
{
    assert( rectangleWrite < maxRectangleCount );
    rects[ rectangleWrite ] = *r;
    colors[ rectangleWrite++ ] = c;
}

- (size_t)rectangleCount
    { return rectangleWrite; }

- (NSRect*)getRectangles
    { return rects; }

- (NSColor**)getColors
    { return colors; }
@end
