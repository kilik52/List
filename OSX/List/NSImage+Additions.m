//
//  NSImage+Additions.m
//  List
//
//  Created by 朱 曦炽 on 13-11-7.
//  Copyright (c) 2013年 Mirroon. All rights reserved.
//

#import "NSImage+Additions.h"

@implementation NSImage (Additions)
- (NSData *) PNGRepresentation
{
    // Create a bitmap representation from the current image
    
    [self lockFocus];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, self.size.width, self.size.height)];
    [self unlockFocus];
    
    return [bitmapRep representationUsingType:NSPNGFileType properties:Nil];
}
@end
