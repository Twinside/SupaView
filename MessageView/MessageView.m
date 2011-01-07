//
//  MessageView.m
//  SupaView
//
//  Created by Vincent Berthoux on 07/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageView.h"


@implementation SVMessageView
- (id)initWithFrame:(NSRect)rectFrame
{
    self = [super initWithFrame:rectFrame];

    if (!self) return self;

    NSColor *beginGradient = 
      [NSColor colorWithDeviceRed:0.1
                            green:0.1
                             blue:0.1
                            alpha:1.0];
    NSColor *endGradient =
      [NSColor colorWithDeviceRed:0.2
                            green:0.2
                             blue:0.2
                            alpha:1.0];

    backGradient = [[NSGradient alloc]
                    initWithColorsAndLocations:beginGradient, (CGFloat)0.0,
                                                 endGradient, (CGFloat)1.0,
                                                   nil];

    return self;
}

- (void)dealloc
{
    [backGradient release];
}

- (void)drawInitialMessage:(NSRect)dirtyRect
{
    [[NSColor whiteColor] setStroke];
    NSFont *msgFont =
    [NSFont fontWithName:@"Helvetica" 
                    size:20];
    NSDictionary *strDrawAttr = 
    [NSDictionary dictionaryWithObjectsAndKeys:
                                msgFont, NSFontAttributeName,
                   [NSColor whiteColor], NSForegroundColorAttributeName
                                       , nil];
    
    CGFloat boxSize = 50.0f;
    CGFloat strokeSize = 5.0f;
    CGFloat boxMargin = 20.0f;
    
    NSRect bounds = [self bounds];
    NSRect rectWhere =
    { .origin = { .x = bounds.origin.x
        + (bounds.size.width - boxSize - boxMargin) / 2
        , .y = bounds.origin.y
        + (bounds.size.height - boxSize - boxMargin) / 2 }
        , .size = { .width = boxSize + boxMargin
            , .height = boxSize + boxMargin } };
    
    NSBezierPath *roundRect = 
    [NSBezierPath bezierPathWithRoundedRect:rectWhere
                                    xRadius:10.0f
                                    yRadius:10.0f];
    
    CGFloat lineDash[] = { 7.0f, 5.0f };
    
    [roundRect setLineWidth:strokeSize];
    [roundRect setLineDash:lineDash
                     count:sizeof(lineDash) / sizeof(CGFloat)
                     phase:0.0];
    [roundRect stroke];
    
    CGFloat textBoxWidth = 240;
    CGFloat textBoxHeight = 25;
    NSRect where = { .origin = { .x = bounds.origin.x
        + (bounds.size.width - textBoxWidth) / 2
        , .y = rectWhere.origin.y
        - boxSize / 2
        - textBoxHeight }
        , .size = { .width = textBoxWidth
            , .height = textBoxHeight * 2 } };
    
    NSString *msgString =
    NSLocalizedStringFromTable(@"InitialMessage", @"Custom", @"A comment");
    
    [msgString drawInRect:where withAttributes:strDrawAttr];
    [[NSColor blackColor] setStroke];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [backGradient drawInRect:[self frame]
                       angle:180+90];
    
    [super drawRect:dirtyRect];
    
    [self drawInitialMessage:dirtyRect];

    // our ancestor is the svfiledragging view
    // handling color overlay drawing.
    [super drawRect:dirtyRect];
    return;
}
@end
