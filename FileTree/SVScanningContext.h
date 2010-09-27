#import "SVProgressNotifiable.h"

@class SVFolderTree;

struct SVScanningContext_t {
    SVFolderTree                **parentStack;
    int                         depth;
    id<SVProgressNotifiable>    receiver;
};

typedef struct SVScanningContext_t SVScanningContext;

