//
//  MyTextFieldCell.m
//  List
//
//  Created by 朱 曦炽 on 13-12-1.
//  Copyright (c) 2013年 Mirroon. All rights reserved.
//

#import "MyTextFieldCell.h"

@implementation MyTextFieldCell
- (NSRect) titleRectForBounds:(NSRect)frame {
    
    CGFloat stringHeight       = self.attributedStringValue.size.height;
    NSRect titleRect          = [super titleRectForBounds:frame];
    titleRect.origin.y = frame.origin.y +
    (frame.size.height - stringHeight) / 2.0;
    return titleRect;
}

- (void) drawInteriorWithFrame:(NSRect)cFrame inView:(NSView*)cView {
    [super drawInteriorWithFrame:[self titleRectForBounds:cFrame] inView:cView];
    
    if ([self isHighlighted])
    {
        NSRect bgFrame = cFrame;
        [[NSColor redColor] set];
        NSRectFill(bgFrame);
        
    }
}
@end
