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

/**
 * Main type used for the storage of the file
 * information. This node store name of a file
 * and it's disk size.
 */
@interface SVFileTree : NSObject {
    FileSize        diskSize;
	NSString        *name;
}

/**
 * Tell if a given url can really be scanned/analysed
 * by this class. Will accept only "local" (filepath)
 * URL.
 */
+ (BOOL)isAcceptableURL:(NSURL*)url;

/**
 * Main method to call to analyse a disk/folder.
 */
+ (SVFileTree*)createFromPath:(NSURL*)filePath
               updateReceiver:(id<SVProgressNotifiable>)receiver
                  endNotifier:(EndNotification)notifier;

/**
 * Initialize only the name, set diskpace to nil
 * imagine protected...
 */
- (id)initWithFilePath:(NSURL*)treeName;

/**
 * Real constructor to build a file
 */
- (id)initWithFilePath:(NSURL*)treeName
               andSize:(FileSize)size;

/**
 * Same as above.
 */
- (id)initWithFileName:(NSString*)filename
               andSize:(FileSize)size;

- (void)dealloc;

- (FileSize)diskSize;
- (NSString*)filename;

/**
 * Create a display node from this file.
 */
- (SVLayoutNode*)createLayoutTree;
@end

NSComparator SvFileTreeComparer;

