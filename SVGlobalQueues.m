//
//  SVGlobalQueues.m
//  SupaView
//
//  Created by Vincent Berthoux on 20/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVGlobalQueues.h"


@implementation SVGlobalQueues
#pragma mark -
#pragma mark class instance methods

#pragma mark -
#pragma mark Singleton methods

+ sharedQueues
{
    static SVGlobalQueues *instance = nil;
    @synchronized(self) {
        if (instance == nil)
            instance = [[SVGlobalQueues alloc] init];
    }
    return instance;
}
- (id)init
{
    self = [super init];
    enqueuedObject = nil;
    return self;
}

- (void)addFileToQueue:(NSURL*)url
{
    [enqueuedObject release];
    enqueuedObject = url;
    [enqueuedObject retain];
    
}

- (NSURL*)getFileFromQueue
{
    NSURL* ret = enqueuedObject;
    enqueuedObject = nil;
    [ret autorelease];
    return ret;
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
