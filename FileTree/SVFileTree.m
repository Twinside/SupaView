//
//  FileTree.m
//  SupaView
//
//  Created by Vincent Berthoux on 14/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVFileTree.h"
#import "SVVolumeTree.h"
#import "SVFolderTree.h"
#import "../LayoutTree/SVLayoutLeaf.h"

FileDeleteRez makeFileDeleteRez( DeleteAction a, SVFileTree *t )
{
    FileDeleteRez ret = { .action = a, .deleted = t };
    return ret;
}

NSComparator SvFileTreeComparer = (NSComparator)^(id obj1, id obj2)
{
        FileSize lSize = [obj1 diskSize];
        FileSize rSize = [obj2 diskSize];
        
        if (lSize < rSize)
            return (NSComparisonResult)NSOrderedDescending;
        
        if (lSize > rSize)
            return (NSComparisonResult)NSOrderedAscending;
        
        return (NSComparisonResult)NSOrderedSame;
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
+ (BOOL)isAcceptableURL:(NSURL*)theURL
{
    if ( ![theURL isFileURL] )
        return NO;
    
    NSNumber *isDirectory;
    [theURL getResourceValue:&isDirectory
                      forKey:NSURLIsDirectoryKey
                       error:NULL];
    
    NSNumber *isVolume;
    [theURL getResourceValue:&isVolume
                      forKey:NSURLIsVolumeKey
                       error:NULL];
    
    return [isVolume boolValue] || [isDirectory boolValue];
}

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

- (FileDeleteRez)deleteNodeWithURLParts:(NSArray*)parts
                                atIndex:(size_t)index
{
    NSString *ourPart = [parts objectAtIndex:index];

    if ( [ourPart isEqualToString:name] )
    {
        if ( index == [parts count] - 1 )
        {
            NSURL   *url = [NSURL fileURLWithPathComponents:parts];

            [[NSWorkspace sharedWorkspace]
                     recycleURLs:[NSArray arrayWithObject:url]
               completionHandler:nil];

            return makeFileDeleteRez( DeletionTodo, self );
        }
        else
            return makeFileDeleteRez( DeletionDigg, self );
    }
    else
        return makeFileDeleteRez( DeletionContinueScan, nil );
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

- (double)advancementPercentage
{
    return -1.0f;
}

- (SVLayoutNode*)createLayoutTree:(int)maxDepth
                          atDepth:(int)depth
{
    SVLayoutNode  *layoutNode =
        [[SVLayoutLeaf alloc] initWithFile:self];

    return [layoutNode autorelease];
}
@end

