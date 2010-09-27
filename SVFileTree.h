//
//  FileTree.h
//  SupaView
//
//  Created by Vincent Berthoux on 14/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SVLayoutTree.h"
#import "SVGraphViz.h"

@class SVLayoutTree;
@class SVFolderTree;

@protocol SVProgressNotifiable
- (void)notifyFileScanned;
@end

typedef void (^EndNotification)();
typedef struct SVScanningContext_t SVScanningContext;

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

- (FileSize)getDiskSize;
- (SVLayoutTree*)createLayoutTree;
- (NSString*)filename;
@end

@interface SVFolderTree : SVFileTree {
    NSMutableArray     *children;
}

- (id)initWithFilePath:(NSURL*)treeName
            andContext:(SVScanningContext*)ctxt;

- (void)dealloc;

- (SVFolderTree*)addChild:(SVFileTree*)subTree;
- (void) populateChildListAtUrl:(NSURL*)url
                    withContext:(SVScanningContext*)ctxt;

- (SVLayoutTree*)createLayoutTree;
@end

NSComparator SvFileTreeComparer;

