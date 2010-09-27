//
//  FileTree.m
//  SupaView
//
//  Created by Vincent Berthoux on 14/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVFileTree.h"
#import "SVVolumeTree.h"

NSComparator SvFileTreeComparer = (NSComparator)^(id obj1, id obj2){
        FileSize lSize = [obj1 diskSize];
        FileSize rSize = [obj2 diskSize];
        
        if (lSize < rSize)
            return (NSComparisonResult)NSOrderedDescending;
        
        if (lSize > rSize)
            return (NSComparisonResult)NSOrderedAscending;
        
        return (NSComparisonResult)NSOrderedSame;
};

struct SVScanningContext_t {
    SVFolderTree                **parentStack;
    int                         depth;
    id<SVProgressNotifiable>    receiver;
};

BOOL isVolume( NSURL*   pathURL )
{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSArray     *volumes = [workspace mountedLocalVolumePaths];
    NSString    *pathStr = [pathURL path];

    for (NSString* path in volumes)
    {
        if ( [pathStr isEqualToString:path] )
            return TRUE;
    }

    return [pathStr isEqualToString:@"/"];
}

@implementation SVFileTree
+ (SVFileTree*)createFromPath:(NSURL*)filePath
               updateReceiver:(id<SVProgressNotifiable>)receiver
                  endNotifier:(EndNotification)notifier
{
    SVFolderTree *rootFolder;

    // alloc before launching the thread to be able
    // to return the object
    if ( isVolume( filePath ) )
        rootFolder = [SVVolume alloc];
    else
        rootFolder = [SVFolderTree alloc];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        SVScanningContext       ctxt =
            { .depth = 0
            , .receiver = receiver
            , .parentStack =
                (SVFolderTree**)malloc( sizeof( SVFolderTree* ) * 256 )
            };

        [rootFolder initWithFilePath:filePath
                          andContext:&ctxt];

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

- (FileSize)diskSize { return diskSize; }

- (id)initWithFilePath:(NSURL*)treeName
{
    self = [super init];

    diskSize = 0;
    name = [treeName lastPathComponent];
    [name retain];

    return self;
}

- (id)initWithFilePath:(NSURL*)treeName
               andSize:(FileSize)size
{
    self = [super init];

    diskSize = size;
    name = [treeName lastPathComponent];
    [name retain];

    return self;
}

- (id)initWithFileName:(NSString*)filename
               andSize:(FileSize)size
{
    self = [super init];
    diskSize = size;
    name = filename;
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

@interface SVFolderTree (Private)
+ (NSArray*)scanObjectInfo;
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

                [theURL getResourceValue:&fileSize
                                  forKey:NSURLFileAllocatedSizeKey
                                   error:NULL];
                
                SVFileTree *sub = 
                    [[SVFileTree alloc] initWithFilePath:theURL
                                                 andSize:[fileSize longLongValue]];
                [self addChild:sub];
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

