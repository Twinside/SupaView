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

@interface SVFileTree : NSObject <SVGraphViz> {
    FileSize        diskSize;
	NSString        *name;
}
+ (SVFileTree*)createFromPath:(NSURL*)filePath;

- (id)initWithFileName:(NSURL*)treeName;
- (id)initWithFileName:(NSURL*)treeName
               andSize:(uint64_t)size;


- (void)dealloc;

- (FileSize)getDiskSize;
- (SVLayoutTree*)createLayoutTree;
- (NSString*)filename;
@end

@interface SVFolderTree : SVFileTree {
    NSMutableArray     *children;
}

- (id)initWithFileName:(NSURL*)treeName;
- (void)dealloc;

- (SVFolderTree*)addChild:(SVFileTree*)subTree;
- (void) populateChildListAtUrl:(NSURL*)url;
- (SVLayoutTree*)createLayoutTree;
@end

