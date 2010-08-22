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
	NSString	*name;
    LayoutTree  *representation;
    FolderTree  *parent;
    FileSize    diskSize;
}
- (id)initWithName:(NSString*)treeName
           andSize:(uint64_t)size
           atPlace:(FolderTree*)parentFolder;

- (id)initWithName:(NSString*)treeName
           atPlace:(FolderTree*)parentFolder;

- (void)dealloc;

- (FileSize)getDiskSize;
- (LayoutTree*)createLayoutTree;
@end

@interface FolderTree : FileTree {
    NSMutableArray     *children;
}

- (id)initWithName:(NSString*)treeName
           atPlace:(FolderTree*)parentFolder;
- (void)dealloc;

- (FolderTree*)addChild:(FileTree*)subTree;
- (void) populateChildList:(NSString*)root;
- (LayoutTree*)createLayoutTree;
@end

