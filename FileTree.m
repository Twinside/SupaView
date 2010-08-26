//
//  FileTree.m
//  SupaView
//
//  Created by Vincent Berthoux on 14/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileTree.h"

@implementation FileTree
+ (FileTree*)createFromPath:(NSURL*)filePath
{
    FolderTree *rootFolder =
        [[FolderTree alloc] initWithName:filePath
                                 atPlace:nil];
    return rootFolder;
}

- (FileSize)getDiskSize
{
    return diskSize;
}

- (id)initWithName:(NSURL*)treeName
           atPlace:(FolderTree*)parentFolder
{
    self = [super init];

    diskSize = 0;
    name = treeName;
    parent = parentFolder;
    [name retain];
    representation = nil;

    return self;
}

- (id)initWithName:(NSURL*)treeName
           andSize:(FileSize)size
           atPlace:(FolderTree*)parentFolder
{
    self = [super init];

    diskSize = size;
    name = treeName;
    parent = parentFolder;
    [name retain];
    representation = nil;

    return self;
}

- (void)dealloc
{
    [name release];
    [representation release];
    [super dealloc];
}

- (LayoutTree*)createLayoutTree
{
    LayoutTree  *layoutNode =
        [[LayoutTree alloc] initWithFile:self];

    return layoutNode;
}
@end

@implementation FolderTree
- (id)initWithName:(NSURL*)treeName
           atPlace:(FolderTree*)parentFolder
{
    self = [super initWithName:treeName
                       atPlace:parentFolder];

    children = [[NSMutableArray alloc] init];
    [self populateChildList];
    return self;
}

- (void)dealloc
{
    [children release];
    [super dealloc];
}

- (void)createFileList
{
	NSFileManager *localFileManager = [[NSFileManager alloc] init];
	NSDirectoryEnumerator *dirEnumerator =
        [localFileManager enumeratorAtURL:name
               includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey,
                                                                    NSURLIsDirectoryKey,
                                                                    nil]
											
                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                             errorHandler:nil];
    
	for (NSURL *theURL in dirEnumerator)
	{
        NSNumber *isDirectory;
        
        [theURL getResourceValue:&isDirectory
						  forKey:NSURLIsDirectoryKey
						   error:NULL];
        
        // Ignore files under the _extras directory
        if ([isDirectory boolValue]==YES)
        {
            [dirEnumerator skipDescendants];
            FolderTree *folder =
                [[FolderTree alloc] initWithName:theURL
                                         atPlace:self];
            [self addChild:folder];
            [folder populateChildList];
        }
        else if ([isDirectory boolValue]==NO)
        {
			NSNumber *fileSize;
			[theURL getResourceValue:&fileSize
                              forKey:NSURLFileSizeKey
                               error:NULL];
			
            [self addChild:[[FileTree alloc]
                                initWithName:theURL
                                     andSize:[fileSize longLongValue]
                                     atPlace:self]];
        }
    }
}

- (void) populateChildList
{
    [self createFileList];
    
    diskSize = 0;
    for ( FileTree *f in children )
        diskSize += [f getDiskSize];
    
    // we sort the file in the descending order.
    [children sortUsingComparator:(NSComparator)^(id obj1, id obj2){
        FileSize lSize = [obj1 getDiskSize];
        FileSize rSize = [obj2 getDiskSize];
        
        if (lSize < rSize)
            return (NSComparisonResult)NSOrderedDescending;
        
        if (lSize > rSize)
            return (NSComparisonResult)NSOrderedAscending;
        
        return (NSComparisonResult)NSOrderedSame; }];
}

- (FolderTree*)addChild:(FileTree*)subTree
{
    [children addObject:subTree];
    return self;
}

- (LayoutTree*)createLayoutTree
{
    return
        [[LayoutTree alloc] initWithFileList:children
                                andTotalSize:diskSize];
}
@end

