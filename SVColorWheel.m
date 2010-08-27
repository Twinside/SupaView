//
//  SVColorWheel.m
//  SupaView
//
//  Created by Vincent Berthoux on 25/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVColorWheel.h"


@implementation SVColorWheel

- (id)init
{
    self = [super init];
    currentLevel = 0;
    maxLevel = 6;
    colorWheel =
        (NSColor**)malloc( sizeof( NSColor* ) * maxLevel );

    colorWheel[ 0 ] = [NSColor redColor];
    colorWheel[ 1 ] = [NSColor orangeColor];
    colorWheel[ 2 ] = [NSColor yellowColor];
    colorWheel[ 3 ] = [NSColor greenColor];
    colorWheel[ 4 ] = [NSColor blueColor];
    colorWheel[ 5 ] = [NSColor whiteColor];
    
    return self;
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
