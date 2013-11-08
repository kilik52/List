//
//  Document.h
//  List
//
//  Created by 朱 曦炽 on 13-11-5.
//  Copyright (c) 2013年 Mirroon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Document : NSDocument <NSTextFieldDelegate>
- (IBAction)addItem:(id)sender;
- (IBAction)removeItem:(id)sender;
- (IBAction)addKey:(id)sender;
- (IBAction)removeKey:(id)sender;
@property (weak) IBOutlet NSTableView *itemTableView;
@property (weak) IBOutlet NSTableView *keyValueTableView;
@end
