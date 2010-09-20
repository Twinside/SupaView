//
//  SVGlobalQueues.h
//  SupaView
//
//  Created by Vincent Berthoux on 20/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SVGlobalQueues : NSObject {
    NSURL*   enqueuedObject;
}

+ sharedQueues;
- (void)addFileToQueue:(NSURL*)url;
- (NSURL*)getFileFromQueue;
@end
