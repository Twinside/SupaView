//
//  MessageView.h
//  SupaView
//
//  Created by Vincent Berthoux on 07/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileDraggingView.h"

/**
 * Class in charge of displaying the initial message of
 * drag'n'drop. It also has autority to handle file drag'n'
 * drop.
 */
@interface SVMessageView : SVFileDraggingView {
    NSGradient  *backGradient;
}

@end

