//
//  FileTree.h
//  SupaView
//
//  Created by Vincent Berthoux on 14/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LayoutTree.h"

@class LayoutTree;
@class FolderTree;

@interface FileTree : NSObject {
	NSURL       *name;
    LayoutTree  *representation;
    FolderTree  *parent;
    FileSize    diskSize;
}
+ (FileTree*)createFromPath:(NSURL*)filePath;

- (id)initWithName:(NSURL*)treeName
           andSize:(uint64_t)size
           atPlace:(FolderTree*)parentFolder;

- (id)initWithName:(NSURL*)treeName
           atPlace:(FolderTree*)parentFolder;

- (void)dealloc;

- (FileSize)getDiskSize;
- (LayoutTree*)createLayoutTree;
@end

@interface FolderTree : FileTree {
    NSMutableArray     *children;
}

- (id)initWithName:(NSURL*)treeName
           atPlace:(FolderTree*)parentFolder;
- (void)dealloc;

- (FolderTree*)addChild:(FileTree*)subTree;
- (void) populateChildList;
- (LayoutTree*)createLayoutTree;
@end

