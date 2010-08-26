//
//  SVColorWheel.h
//  SupaView
//
//  Created by Vincent Berthoux on 25/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SVColorWheel : NSObject {
    NSColor**      colorWheel;
    NSInteger      currentLevel;
    NSInteger      maxLevel;
}

- (id)init;

- (void)pushColor;
- (void)popColor;
- (NSColor*)getLevelColor;

@end
