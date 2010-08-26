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
	NSURL       *name;
    SVLayoutTree  *representation;
    SVFolderTree  *parent;
    FileSize    diskSize;
}
+ (SVFileTree*)createFromPath:(NSURL*)filePath;

- (id)initWithName:(NSURL*)treeName
           andSize:(uint64_t)size
           atPlace:(SVFolderTree*)parentFolder;

- (id)initWithName:(NSURL*)treeName
           atPlace:(SVFolderTree*)parentFolder;

- (void)dealloc;

- (FileSize)getDiskSize;
- (SVLayoutTree*)createLayoutTree;
- (NSURL*)name;
@end

@interface SVFolderTree : SVFileTree {
    NSMutableArray     *children;
}

- (id)initWithName:(NSURL*)treeName
           atPlace:(SVFolderTree*)parentFolder;
- (void)dealloc;

- (SVFolderTree*)addChild:(SVFileTree*)subTree;
- (void) populateChildList;
- (SVLayoutTree*)createLayoutTree;
@end

