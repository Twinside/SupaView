//
//  FileTree.m
//  SupaView
//
//  Created by Vincent Berthoux on 14/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileTree.h"

@implementation FileTree
- (FileSize)getDiskSize
{
    return diskSize;
}

- (id)initWithName:(NSString*)treeName
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

- (id)initWithName:(NSString*)treeName
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
    return nil;
}
@end

@implementation FolderTree
- (id)initWithName:(NSString*)treeName
           atPlace:(FolderTree*)parentFolder
{
    self = [super initWithName:treeName
                       atPlace:parentFolder];

    children = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc
{
    [children release];
    [super dealloc];
}

+ (void) createFileList: (NSString*)root atPlace:(FolderTree*)parentFolder
{
	NSFileManager *localFileManager = [[NSFileManager alloc] init];
	NSURL		  *rootUrl = [NSURL fileURLWithPath:root];
	NSDirectoryEnumerator *dirEnumerator = [localFileManager enumeratorAtURL:rootUrl
											
                                                  includingPropertiesForKeys:[NSArray arrayWithObjects:
                                                                              NSURLNameKey,
                                                                              NSURLIsDirectoryKey,
                                                                              nil]
											
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
											
                                                                errorHandler:nil];
    
	for (NSURL *theURL in dirEnumerator)
	{
        // Retrieve the file name. From NSURLNameKey, cached during the enumeration.
        NSString *fileName;
        [theURL getResourceValue:&fileName
						  forKey:NSURLNameKey
						   error:NULL];
		
        // Retrieve whether a directory. From NSURLIsDirectoryKey
        // also cached during the enumeration.
        NSNumber *isDirectory;
        [theURL getResourceValue:&isDirectory
						  forKey:NSURLIsDirectoryKey
						   error:NULL];
        
        // Ignore files under the _extras directory
        if ([isDirectory boolValue]==YES)
        {
            [dirEnumerator skipDescendants];
            FolderTree *folder =
                [[FolderTree alloc] initWithName:fileName
                                         atPlace:parentFolder];
            [parentFolder addChild:folder];
            [folder populateChildList:root];
        }
        else if ([isDirectory boolValue]==NO)
        {
			NSNumber *fileSize;
			[theURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
			
            FileTree    *f;
            f = [[FileTree alloc] initWithName:fileName
                                       andSize:[fileSize longLongValue]
                                       atPlace:parentFolder];
            [parentFolder addChild:f];
        }		
    }
}

- (void) populateChildList:(NSString*)root
{
    NSString *thisRoot = [[root stringByAppendingString:@"/"]
                                stringByAppendingString:name];
    
    [FolderTree createFileList:thisRoot
                       atPlace:self];
    
    for ( FileTree *f in children )
        diskSize += [f getDiskSize];
}

- (FolderTree*)addChild:(FileTree*)subTree
{
    [children addObject:subTree];
    return self;
}

- (LayoutTree*)createLayoutTree
{
    LayoutTree  *ourTree =
        [[LayoutTree alloc] initWithFileList:children
                                andTotalSize:diskSize];

    return ourTree;
}
@end

