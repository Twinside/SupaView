

@implementation SVVolume
- (id)initWithFileName:(NSURL*)treeName
{
    self = [SVFileTree initWithFileName:treeName];

    NSDictionary* fileAttributes =
        [[NSFileManager defaultManager] fileSystemAttributesAtPath:treeName];

    emptySpace = [[fileAttributes objectForKey:NSFileSystemFreeSize] longLongValue];

    return self;
}

- (SVLayoutTree*)createLayoutTree
{
    return nil;
}
@end
