//
//  FileTree.h
//  SupaView
//
//  Created by Vincent Berthoux on 14/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SVLayoutNode.h"
#import "SVProgressNotifiable.h"

@class SVLayoutNode;

typedef void (^EndNotification)();

@interface SVFileTree : NSObject {
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
- (SVLayoutNode*)createLayoutTree;
- (NSString*)filename;
@end

NSComparator SvFileTreeComparer;

