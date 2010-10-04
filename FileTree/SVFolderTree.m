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
            ctxt->parentStack[ctxt->depth++] = self;

            //[dirEnumerator skipDescendants];
            SVFolderTree *folder =
                [[SVFolderTree alloc] initWithFilePath:theURL
                                            andContext:ctxt];
            ctxt->depth--;

            [children addObject:folder];
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

- (SVLayoutNode*)createLayoutTree
{
    if ( [children count] == 0 )
        return nil;

    SVLayoutNode *ret =
        [[SVLayoutFolder alloc] initWithFileList:children
                                         forNode:self
                                    andTotalSize:diskSize];
    
    return [ret autorelease];
}
@end


@implementation SVFolderTree (Private)
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

@end
