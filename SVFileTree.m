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

struct SVScanningContext_t {
    SVFolderTree                **parentStack;
    int                         depth;
    id<SVProgressNotifiable>    receiver;
};

@implementation SVFileTree
+ (SVFileTree*)createFromPath:(NSURL*)filePath
               updateReceiver:(id<SVProgressNotifiable>)receiver
                  endNotifier:(EndNotification)notifier
{
    SVFolderTree *rootFolder = [SVFolderTree alloc];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        SVScanningContext       ctxt =
            { .depth = 0
            , .receiver = receiver
            , .parentStack =
                (SVFolderTree**)malloc( sizeof( SVFolderTree* ) * 256 )
            };

        [rootFolder initWithFileName:filePath
                         withContext:&ctxt];

        free( ctxt.parentStack );

        dispatch_async( dispatch_get_main_queue()
                      , ^{notifier();} );
    });
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

- (id)initWithFileName:(NSURL*)treeName
{
    self = [super init];

    diskSize = 0;
    name = [treeName lastPathComponent];
    [name retain];

    return self;
}

- (id)initWithFileName:(NSURL*)treeName
           andSize:(FileSize)size
{
    self = [super init];

    diskSize = size;
    name = [treeName lastPathComponent];
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
- (id)initWithFileName:(NSURL*)treeName
           withContext:(SVScanningContext*)ctxt
{
    self = [super initWithFileName:treeName];

    children = [[NSMutableArray alloc] init];
    [self populateChildListAtUrl:treeName
                     withContext:ctxt];
    return self;
}

- (void)dealloc
{
    [children release];
    [super dealloc];
}

- (void)createFileListAtUrl:(NSURL*)url
                withContext:(SVScanningContext*)ctxt
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
        
        NSNumber *isVolume;
        [theURL getResourceValue:&isVolume
						  forKey:NSURLIsVolumeKey
						   error:NULL];

		NSNumber *isLink;
        [theURL getResourceValue:&isLink
						  forKey:NSURLIsSymbolicLinkKey
						   error:NULL];

        // don't follow other drive
        // or symbolic link
        if ([isVolume boolValue] == YES || [isLink boolValue] == YES )
            continue;

        // Ignore files under the _extras directory
        if ([isDirectory boolValue] == YES)
        {
            ctxt->parentStack[ctxt->depth++] = self;

            //[dirEnumerator skipDescendants];
            SVFolderTree *folder =
                [[SVFolderTree alloc] initWithFileName:theURL
                                           withContext:ctxt];
            ctxt->depth--;

            [self addChild:folder];
            [folder release];
            [ctxt->receiver notifyFileScanned];
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
                    [[SVFileTree alloc] initWithFileName:theURL
                                                 andSize:[fileSize longLongValue]];
                [self addChild:sub];
                FileSize subSize = [sub getDiskSize];
                diskSize += subSize;

                // propagate upward file size
                SVFolderTree **parents = ctxt->parentStack;
                for ( int i = ctxt->depth - 1; i >= 0; i-- )
                    parents[i]->diskSize += subSize;

                [sub release];
                [ctxt->receiver notifyFileScanned];
            }
        }
    }
}

- (void) populateChildListAtUrl:(NSURL*)url
                    withContext:(SVScanningContext*)ctxt
{
    [self createFileListAtUrl:url
                  withContext:ctxt];
    
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

