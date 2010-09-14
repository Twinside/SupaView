//
//  FileTree.m
//  SupaView
//
//  Created by Vincent Berthoux on 14/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVFileTree.h"

/* seemingly fast function to list information
 * try to digg it sometime.
 */
/*
- (unsigned long long) fastFolderSizeAtFSRef:(FSRef*)theFileRef
{
    FSIterator    thisDirEnum = NULL;
    unsigned long long totalSize = 0;

    // Iterate the directory contents, recursing as necessary
    if (FSOpenIterator(theFileRef, kFSIterateFlat, &thisDirEnum) == noErr)
    {
        const ItemCount kMaxEntriesPerFetch = 256;
        ItemCount actualFetched;
        FSRef    fetchedRefs[kMaxEntriesPerFetch];
        FSCatalogInfo fetchedInfos[kMaxEntriesPerFetch];

        // DCJ Note right now this is only fetching data fork sizes...
        // if we decide to include
        // resource forks we will have to add kFSCatInfoRsrcSizes

        OSErr fsErr = FSGetCatalogInfoBulk(thisDirEnum, kMaxEntriesPerFetch, &actualFetched,
                                        NULL
                                        , kFSCatInfoDataSizes | kFSCatInfoNodeFlags, fetchedInfos,
                                        fetchedRefs, NULL, NULL);
        while ((fsErr == noErr) || (fsErr == errFSNoMoreItems))
        {
            ItemCount thisIndex;
            for (thisIndex = 0; thisIndex < actualFetched; thisIndex++)
            {
                // Recurse if it's a folder
                if (fetchedInfos[thisIndex].nodeFlags & kFSNodeIsDirectoryMask)
                {
                    totalSize += [self fastFolderSizeAtFSRef:&fetchedRefs[thisIndex]];
                }
                else
                {
                    // add the size for this item
                    totalSize += fetchedInfos [thisIndex].dataLogicalSize;
                }
            }

            if (fsErr == errFSNoMoreItems)
            {
                break;
            }
            else
            {
                // get more items
                fsErr = FSGetCatalogInfoBulk(thisDirEnum, kMaxEntriesPerFetch, &actualFetched,
                                        NULL, kFSCatInfoDataSizes | kFSCatInfoNodeFlags, fetchedInfos, fetchedRefs, NULL, NULL);
            }
        }
        FSCloseIterator(thisDirEnum);
    }
    return totalSize;
} // */

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
    fprintf( f, "p%p [label=\"%i|%s\" shape=record]\n"
           , self
           , (int)diskSize
           , [name  UTF8String]);
}

- (NSString*)filename { return name; }

- (FileSize)getDiskSize
{
    return diskSize;
}

- (id)initWithName:(NSURL*)treeName
           atPlace:(SVFolderTree*)parentFolder
{
    self = [super init];

    diskSize = 0;
    name = [treeName lastPathComponent];
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
    name = [treeName lastPathComponent];
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
    [self populateChildListAtUrl:treeName];
    return self;
}

- (void)dealloc
{
    [children release];
    [super dealloc];
}

- (void)createFileListAtUrl:(NSURL*)url
{
	NSFileManager *localFileManager = [[NSFileManager alloc] init];
	NSDirectoryEnumerator *dirEnumerator =
        [localFileManager enumeratorAtURL:url
               includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey,
                                                                    NSURLIsDirectoryKey,
                                                                    nil]
											
                                  options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                             errorHandler:nil];
    
	for (NSURL *theURL in dirEnumerator)
	{
        NSNumber *isDirectory;
        
        [theURL getResourceValue:&isDirectory
						  forKey:NSURLIsDirectoryKey
						   error:NULL];

        NSNumber *isFile;
        [theURL getResourceValue:&isFile
						  forKey:NSURLIsRegularFileKey
						   error:NULL];
        
        // Ignore files under the _extras directory
        if ([isDirectory boolValue]==YES)
        {
            //[dirEnumerator skipDescendants];
            SVFolderTree *folder =
                [[SVFolderTree alloc] initWithName:theURL
                                         atPlace:self];
            [self addChild:folder];
            [folder release];
        }
        else // if ([isFile boolValue] == NO)
        {
            NSNumber *isAlias;
			[theURL getResourceValue:&isAlias
                              forKey:NSURLIsAliasFileKey
                               error:NULL];

            if ([isAlias boolValue] == NO)
            {
                NSNumber *fileSize;
                /*
                [theURL getResourceValue:&fileSize
                                forKey:NSURLFileSizeKey
                                error:NULL];
                                // */
                                //
                [theURL getResourceValue:&fileSize
                                forKey:NSURLFileAllocatedSizeKey
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
}

- (void) populateChildListAtUrl:(NSURL*)url
{
    [self createFileListAtUrl:url];
    
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
    if ( [children count] == 0 )
        return nil;
    
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

