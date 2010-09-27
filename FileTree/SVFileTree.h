//
//  FileTree.h
//  SupaView
//
//  Created by Vincent Berthoux on 14/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SVLayoutTree.h"
#import "SVProgressNotifiable.h"
#import "../SVGraphViz.h"

@class SVLayoutTree;

typedef void (^EndNotification)();

@interface SVFileTree : NSObject <SVGraphViz> {
    FileSize        diskSize;
	NSString        *name;
}
+ (SVFileTree*)createFromPath:(NSURL*)filePath
               updateReceiver:(id<SVProgressNotifiable>)receiver
                  endNotifier:(EndNotification)notifier;

- (id)initWithFilePath:(NSURL*)treeName;
- (id)initWithFilePath:(NSURL*)treeName
               andSize:(FileSize)size;

- (id)initWithFileName:(NSString*)filename
               andSize:(FileSize)size;

- (void)dealloc;

- (FileSize)diskSize;
- (SVLayoutTree*)createLayoutTree;
- (NSString*)filename;
@end

NSComparator SvFileTreeComparer;

