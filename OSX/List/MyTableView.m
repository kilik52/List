//
//  MyTableView.m
//  List
//
//  Created by 朱 曦炽 on 13-12-1.
//  Copyright (c) 2013年 Mirroon. All rights reserved.
//

#import "MyTableView.h"

@implementation MyTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (void)highlightSelectionInClipRect:(NSRect)theClipRect
{
    [super highlightSelectionInClipRect:theClipRect];
}
@end
