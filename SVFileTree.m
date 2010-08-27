//
//  FileTree.m
//  SupaView
//
//  Created by Vincent Berthoux on 14/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVFileTree.h"

@implementation SVFileTree
+ (SVFileTree*)createFromPath:(NSURL*)filePath
{
    SVFolderTree *rootFolder =
        [[SVFolderTree alloc] initWithName:filePath
                                 atPlace:nil];
    return rootFolder;
}

- (void)dumpToFile:(FILE*)f
{
    fprintf( f, "p%p [label=\"%s\" shape=box]\n"
           , self, [[name lastPathComponent] UTF8String ]);
}

- (NSURL*)name { return name; }
- (NSString*)filename { return [name lastPathComponent]; }

- (FileSize)getDiskSize
{
    return diskSize;
}

- (id)initWithName:(NSURL*)treeName
           atPlace:(SVFolderTree*)parentFolder
{
    self = [super init];

    diskSize = 0;
    name = treeName;
    parent = parentFolder;
    [name retain];

    return self;
}

- (id)initWithName:(NSURL*)treeName
           andSize:(FileSize)size
           atPlace:(SVFolderTree*)parentFolder
{
    self = [super init];

    diskSize = size;
    name = treeName;
    parent = parentFolder;
    [name retain];

    return self;
}

- (void)dealloc
{
    [name release];
    [super dealloc];
}

- (SVLayoutTree*)createLayoutTree
{
    SVLayoutTree  *layoutNode =
        [[SVLayoutTree alloc] initWithFile:self];

    return layoutNode;
}
@end

@implementation SVFolderTree
- (id)initWithName:(NSURL*)treeName
           atPlace:(SVFolderTree*)parentFolder
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
            SVFolderTree *folder =
                [[SVFolderTree alloc] initWithName:theURL
                                         atPlace:self];
            [self addChild:folder];
            [folder release];
        }
        else if ([isDirectory boolValue]==NO)
        {
			NSNumber *fileSize;
			[theURL getResourceValue:&fileSize
                              forKey:NSURLFileSizeKey
                               error:NULL];
			
            SVFileTree *sub = 
                [[SVFileTree alloc] initWithName:theURL
                                         andSize:[fileSize longLongValue]
                                         atPlace:self];
            [self addChild:sub];
            [sub release];
        }
    }
}

- (void) populateChildList
{
    [self createFileList];
    
    diskSize = 0;
    for ( SVFileTree *f in children )
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

- (SVFolderTree*)addChild:(SVFileTree*)subTree
{
    [children addObject:subTree];
    return self;
}

- (SVLayoutTree*)createLayoutTree
{
    return
        [[SVLayoutTree alloc] initWithFileList:children
                                       forNode:self
                                  andTotalSize:diskSize];
}

- (void)dumpToFile:(FILE*)f
{
    [super dumpToFile:f];

    for ( SVFileTree* child in children )
    {
        fprintf( f, "p%p -> p%p\n"
               , self, child );
        [child dumpToFile:f];
        
    }
}
@end

