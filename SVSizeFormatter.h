#import <Cocoa/Cocoa.h>
#import "Definitions.h"

@interface SVSizeFormatter : NSObject {
    NSString    *byteWord;
    NSString    *unitLetter;
    FileSize    base;
}

+ (SVSizeFormatter*)sharedInstance;
- (NSString*)formatSize:(FileSize)size;
@end

