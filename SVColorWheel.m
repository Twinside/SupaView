//
//  SVColorWheel.m
//  SupaView
//
//  Created by Vincent Berthoux on 25/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVColorWheel.h"


NSColor*    colorFromHtmlVal( uint32_t c )
{
    uint32_t    r = (c & 0x00FF0000) >> (2 * 8);
    uint32_t    g = (c & 0x0000FF00) >> 8;
    uint32_t    b = c & 0x000000FF;

    return [NSColor colorWithCalibratedRed:(float)r / 255.0f
                                     green:(float)g / 255.0f
                                      blue:(float)b / 255.0f
                                     alpha:1.0f];
}

static uint32_t    colorList[] =
    { 0x00E68164
    //, 0x00ED987E
    //, 0x00F6B495
    , 0x00F4C7A2
    , 0x00EFF0BE
    , 0x00DFECC0
    , 0x00CFE8C2
    , 0x00C2E5C4
    , 0x00A8DEC7
    , 0x007BDECA
    };

@implementation SVColorWheel

- (id)init
{
    self = [super init];
    currentLevel = 0;
    maxLevel = sizeof( colorList ) / sizeof( uint32_t );

    colorWheel =
        (NSColor**)malloc( sizeof( NSColor* ) * maxLevel );

    for ( NSInteger i = 0; i < maxLevel; i++ )
    {
        colorWheel[ i ] = colorFromHtmlVal( colorList[i] );
        [colorWheel[ i ] retain];
    }
    
    return self;
}

- (void)dealloc
{
    for ( NSInteger i = 0; i < maxLevel; i++ )
        [colorWheel[ i ] release];

    [super dealloc];
}

- (void)pushColor
{
    currentLevel++;
}

- (void)popColor
{
    currentLevel--;
    assert( currentLevel >= 0 );
}

- (NSColor*)getLevelColor
    { return colorWheel[ currentLevel % maxLevel ]; }
@end
