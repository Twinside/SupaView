//
//  GeometryGatherer.h
//  SupaView
//
//  Created by Vincent Berthoux on 23/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SVStringDraw : NSObject {
    // put instances variable here
    NSString    *str;
    NSRect      pos;
}
- (id)initWithString:(NSString*)s atPlace:(NSRect*)position;
- (NSString*)text;
- (NSRect*)position;
- (void)dealloc;
@end

@interface SVGeometryGatherer : NSObject {
    size_t  rectangleWrite;
    size_t  maxRectangleCount;
    NSRect  frameRect;
    NSRect  *rects;
    NSColor **colors;

    NSMutableArray  *textWrite;
}

- (id)initWithRectCount:(int)count;
- (void)dealloc;

- (void)startGathering:(NSRect*)frameView;

- (void)addText:(NSString*)str inRect:(NSRect*)rect;

- (void)addRectangle:(NSRect*)r
           withColor:(NSColor*)c;

- (size_t)rectangleCount;
- (NSRect*)getRectangles;
- (NSColor**)getColors;
- (NSMutableArray*)getText;

@end
