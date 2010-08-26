//
//  GeometryGatherer.h
//  SupaView
//
//  Created by Vincent Berthoux on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GeometryGatherer : NSObject {
    size_t  rectangleWrite;
    size_t  maxRectangleCount;
    NSRect  *rects;
    NSColor **colors;
}

- (id)initWithRectCount:(int)count;
- (void)dealloc;

- (void)addRectangle:(NSRect*)r
           withColor:(NSColor*)c;

- (size_t)rectangleCount;
- (NSRect*)getRectangles;
- (NSColor**)getColors;

- (void)pushColor;
- (void)popColor;
@end
