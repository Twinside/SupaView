/*
 *  Definitions.h
 *  SupaView
 *
 *  Created by Vincent Berthoux on 23/08/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#import <stdint.h>

typedef uint64_t    FileSize;

typedef enum LayoutKind_t {
    LayoutVertical = 1,
    LayoutHorizontal = 2,
    LayoutMask = LayoutVertical
               | LayoutHorizontal,

    SelectionAtLeft = 4,
    SelectionAtRight = 8,
    SelectionMask = SelectionAtLeft
                  | SelectionAtRight
} LayoutKind;

