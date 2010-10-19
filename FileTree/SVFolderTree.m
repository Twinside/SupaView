#import "SVFolderTree.h"
#import "SVScanningContext.h"
#import "../LayoutTree/SVLayoutFolder.h"

@interface SVFolderTree (Private)
/**
 * Helper function to extract all the information
 * we are interested in regarding to a file/folder.
 */
+ (NSArray*)scanObjectInfo;

/**
 * Function starting the folder scan
 */
- (void) populateChildListAtUrl:(NSURL*)url
                    withContext:(SVScanningContext*)ctxt;

/**
 * init without scanning, usefull in the big multi-threading
 * of things.
 */
- (id)initWithFileURL:(NSURL*)url andContext:(SVScanningContext*)ctxt;
@end

@implementation SVFolderTree
- (id)initWithFilePath:(NSURL*)treeName
            andContext:(SVScanningContext*)ctxt
{
    self = [super initWithFilePath:treeName];

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
               includingPropertiesForKeys:[SVFolderTree scanObjectInfo]
                                  options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                             errorHandler:nil];
    
	for (NSURL *theURL in dirEnumerator)
	{
        NSNumber *isDirectory;
        
        [theURL getResourceValue:&isDirectory
						  forKey:NSURLIsDirectoryKey
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
            // allocate and initialize object first.
            SVFolderTree *folder =
                [[SVFolderTree alloc] initWithFileURL:theURL
                                           andContext:ctxt];
            
            // insert it into the tree, now should be able to
            // create a layout tree without problem
            [children addObject:folder];
            
            // then start scanning.
            ctxt->parentStack[ctxt->depth++] = self;
            [folder populateChildListAtUrl:theURL withContext:ctxt];
            ctxt->depth--;

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

                [theURL getResourceValue:&fileSize
                                  forKey:NSURLFileAllocatedSizeKey
                                   error:NULL];
                
                SVFileTree *sub = 
                    [[SVFileTree alloc] initWithFilePath:theURL
                                                 andSize:[fileSize longLongValue]];
                [children addObject:sub];

                FileSize subSize = [sub diskSize];
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

    [localFileManager release];
}

- (SVLayoutNode*)createLayoutTree:(int)maxDepth
                          atDepth:(int)depth
{
    if ( [children count] == 0 || diskSize == 0 || depth >= maxDepth )
        return nil;

    NSMutableArray *childrenLayout =
        [[NSMutableArray alloc] initWithCapacity:[children count]];

    NSUInteger originalSize = [children count];
    for ( NSUInteger i = 0; i < originalSize; i++ )
    {
        SVLayoutNode *sub =
            [[children objectAtIndex:i] createLayoutTree:maxDepth
                                                 atDepth:depth + 1];
        
        if (sub != nil)
            [childrenLayout addObject:sub];
    }

    SVLayoutNode *ret;
    
    if ([childrenLayout count] > 0)
        ret = [[SVLayoutFolder alloc] initWithFileList:childrenLayout
                                               forNode:self
                                          andTotalSize:diskSize];
    else
        ret = [[SVLayoutLeaf alloc] initWithFile:self];

    [childrenLayout release];
    return [ret autorelease];
}
- (size_t)childCount { return [children count]; }
@end


@implementation SVFolderTree (Private)
- (id)initWithFileURL:(NSURL*)url andContext:(SVScanningContext*)ctxt
{
    self = [super initWithFilePath:url];
    children = [[NSMutableArray alloc] init];
    return self;
}

+ (NSArray*)scanObjectInfo
{
    static NSArray *scanObjectInfo = nil;

    if ( scanObjectInfo == nil )
    {
        scanObjectInfo = 
            [[NSArray arrayWithObjects: NSURLNameKey
                                      , NSURLIsDirectoryKey
                                      , NSURLIsVolumeKey
                                      , NSURLIsSymbolicLinkKey
                                      , NSURLFileAllocatedSizeKey
                                      , nil] retain];
    }
    return scanObjectInfo;
}

- (void) populateChildListAtUrl:(NSURL*)url
                    withContext:(SVScanningContext*)ctxt
{
    NSAutoreleasePool *pool =
        [[NSAutoreleasePool alloc] init];

    [self createFileListAtUrl:url
                  withContext:ctxt];
    
    // we sort the file in the descending order.
    [children sortUsingComparator:SvFileTreeComparer];

    [pool drain];
}

- (FileDeleteRez)deleteNodeWithURLParts:(NSArray*)parts
                               atIndex:(size_t)index
{
    FileDeleteRez selfAction =
        [super deleteNodeWithURLParts:parts atIndex:index];

    if ( selfAction.action != DeletionDigg )
        return selfAction;

    int idx = 0;
    for (SVFileTree *child in children)
    {
        FileSize beforeDeletion = [child diskSize];
        FileDeleteRez subAction = 
            [child deleteNodeWithURLParts:parts atIndex:index+1];

        switch ( subAction.action )
        {
        case DeletionTodo:
            /* Remove it from our children */
            diskSize -= beforeDeletion;
            [subAction.deleted retain];
            [children removeObjectAtIndex:idx];
            return makeFileDeleteRez( DeletionEnd
                                    , subAction.deleted );

        case DeletionEnd:
            /* don't bother doing anything else */
            diskSize -= beforeDeletion - [child diskSize];
            return subAction;

        case DeletionContinueScan:
            /* well, that's not him */
            break;

        case DeletionDigg:
            assert( DeletionDigg == -1 );
            break;
        }

        idx++;
    }
    return makeFileDeleteRez( DeletionEnd, nil );
}
@end
