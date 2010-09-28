#import "SVSizeFormatter.h"

@implementation SVSizeFormatter
- (id)init
{
    self = [super init];

    byteWord = NSLocalizedStringFromTable(@"bytes", @"Custom", @"A comment");
    [byteWord retain];

    unitLetter = NSLocalizedStringFromTable(@"bytesAcronym", @"Custom", @"A comment");
    [unitLetter retain];

    // beginning with snow leopard, Finder show fle size in base 1000
    // we are consistent with that.
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_4_1)
        base = 1000;
    else base = 1024;

    return self;
}

+ (SVSizeFormatter*)sharedInstance
{
    static SVSizeFormatter *instance = nil;

    if (instance == nil)
        instance = [[SVSizeFormatter alloc] init];

    return instance;
}

- (NSString*)formatSize:(FileSize)size
{
	float floatSize = size;

	if (size < base - 1)
    { 
		return([NSString stringWithFormat:@"%i %@", size, byteWord]);
    }

	floatSize = floatSize / base;
	if (floatSize < base - 1 )
		return([NSString stringWithFormat:@"%1.1f K%@",floatSize, unitLetter]);

	floatSize = floatSize / base;
	if ( floatSize < base - 1 )
		return([NSString stringWithFormat:@"%1.1f M%@",floatSize, unitLetter]);

	floatSize = floatSize / base;

	return([NSString stringWithFormat:@"%1.1f G%@",floatSize, unitLetter]);
}
@end

