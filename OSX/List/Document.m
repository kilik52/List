//
//  Document.m
//  List
//
//  Created by 朱 曦炽 on 13-11-5.
//  Copyright (c) 2013年 Mirroon. All rights reserved.
//

#import "Document.h"

@interface Document ()
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *itemKeys;
@end

@implementation Document

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        self.items = [[NSMutableArray alloc] init];
        
        // a default key is 'Name'
        self.itemKeys = [[NSMutableArray alloc] initWithObjects:@"Name", nil];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"keys":self.itemKeys, @"items":self.items} options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    return jsonData;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSError *error = nil;
    NSDictionary *importDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    NSArray *importKeys = [importDict objectForKey:@"keys"];
    NSArray *importItems = [importDict objectForKey:@"items"];
    
    self.itemKeys = [[NSMutableArray alloc] initWithArray:importKeys];
    
    self.items = [[NSMutableArray alloc] init];
    for (NSDictionary *importItem in importItems) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:importItem];
        [self.items addObject:dict];
    }
    
    return YES;
}

- (IBAction)addItem:(id)sender {
    static int i = 1;
    NSString *newItemName = [NSString stringWithFormat:@"Item%02d",i++];
    
    NSMutableDictionary *itemDict = [[NSMutableDictionary alloc] initWithDictionary:@{@"Name":newItemName}];
    [self.items addObject:itemDict];
    
    // 2. Insert the row at last
    NSInteger newRowIndex = self.items.count-1;
    
    // 3. Insert new row in the table view
    [self.itemTableView beginUpdates];
    [self.itemTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:newRowIndex] withAnimation:NSTableViewAnimationEffectGap];
    [self.itemTableView endUpdates];
    
    // 4. Select the new bug and scroll to make sure it's visible
    [self.itemTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newRowIndex] byExtendingSelection:NO];
    [self.itemTableView scrollRowToVisible:newRowIndex];
}

- (IBAction)removeItem:(id)sender {
    if (self.itemTableView.selectedRow >= 0 && self.itemTableView.selectedRow < self.items.count) {
        NSInteger selectedRow = self.itemTableView.selectedRow;
        [self.items removeObjectAtIndex:selectedRow];
        // 3. Remove the selected row from the table view.
        [self.itemTableView beginUpdates];
        [self.itemTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedRow] withAnimation:NSTableViewAnimationSlideRight];
        [self.itemTableView endUpdates];
        
        // 4. Select the new row
        if (selectedRow >= self.items.count) {
            selectedRow = self.items.count - 1;
        }
        [self.itemTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
        [self.itemTableView scrollRowToVisible:selectedRow];
    }
}

- (IBAction)addKeyValue:(id)sender {
    static int i=1;
    [self.itemKeys addObject:[NSString stringWithFormat:@"Key%02d",i++]];
    
    // 3. Insert new row in the table view
    NSInteger newRowIndex = self.itemKeys.count-1;
    [self.keyValueTableView beginUpdates];
    [self.keyValueTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:newRowIndex] withAnimation:NSTableViewAnimationEffectGap];
    [self.keyValueTableView endUpdates];
    
    // 4. Select the new bug and scroll to make sure it's visible
    [self.keyValueTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newRowIndex] byExtendingSelection:NO];
    [self.keyValueTableView scrollRowToVisible:newRowIndex];
}

- (IBAction)removeKeyValue:(id)sender {
    return; // it's quite dangrous
    
    if (self.keyValueTableView.selectedRow >= 0 && self.keyValueTableView.selectedRow < self.itemKeys.count) {
        NSInteger selectedRow = self.keyValueTableView.selectedRow;
        [self.itemKeys removeObjectAtIndex:selectedRow];
        // 3. Remove the selected row from the table view.
        [self.keyValueTableView beginUpdates];
        [self.keyValueTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedRow] withAnimation:NSTableViewAnimationSlideRight];
        [self.keyValueTableView endUpdates];
        
        // 4. Select the new row
        if (selectedRow >= self.itemKeys.count) {
            selectedRow = self.itemKeys.count - 1;
        }
        [self.keyValueTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
        [self.keyValueTableView scrollRowToVisible:selectedRow];
    }
}

- (NSMutableDictionary*)selectedItem
{
    if (self.itemTableView.selectedRow >= 0 && self.itemTableView.selectedRow < self.items.count) {
        return [self.items objectAtIndex:self.itemTableView.selectedRow];
    }
    return nil;
}

#pragma mark - NSTableViewDelegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    // Since this is a single-column table view, this would not be necessary.
    // But it's a good practice to do it in order by remember it when a table is multicolumn.
    if( [tableColumn.identifier isEqualToString:@"ItemColumn"] )
    {
        NSMutableDictionary *item = [self.items objectAtIndex:row];
        cellView.textField.stringValue = [item objectForKey:@"Name"];
        return cellView;
    }
    else if( [tableColumn.identifier isEqualToString:@"KeyColumn"] )
    {
        NSString *key = [self.itemKeys objectAtIndex:row];
        cellView.textField.stringValue = key;
        
        return cellView;
    }
    else if( [tableColumn.identifier isEqualToString:@"ValueColumn"] )
    {
        NSMutableDictionary *item = [self selectedItem];
        NSString *key = [self.itemKeys objectAtIndex:row];
        NSString *obj = [item objectForKey:key];
        
        if (obj) {
            cellView.textField.stringValue = obj;
        }
        else {
            cellView.textField.stringValue = @"";
        }
        return cellView;
    }
    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if( tableView == self.itemTableView )
    {
        return [self.items count];
    }
    else if (tableView == self.keyValueTableView)
    {
        if ([self selectedItem] == nil) {
            return 0;
        }
        return [self.itemKeys count];
    }
    
    return 0;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSTableView *tableView = [aNotification object];
    if (tableView == self.itemTableView) {
        [self.keyValueTableView reloadData];
    }
}

#pragma mark - NSTextFieldDelegate
- (void)controlTextDidEndEditing:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    NSTableCellView *cellView = (NSTableCellView*)[textField superview];
    NSInteger row = [self.keyValueTableView rowForView:cellView];
    NSInteger textFieldType = [textField tag];
    NSMutableDictionary *item = [self selectedItem];
    
    if (item) {
        // change key
        if (textFieldType == 1) {
            NSString *oldKeyName = [self.itemKeys objectAtIndex:row];
            [self.itemKeys replaceObjectAtIndex:row withObject:textField.stringValue];
            
            for (NSMutableDictionary *dict in self.items) {
                if ([dict objectForKey:oldKeyName]) {
                    [dict setObject:[dict objectForKey:oldKeyName] forKey:textField.stringValue];
                    [dict removeObjectForKey:oldKeyName];
                }
            }
        }
        
        // change value
        if (textFieldType == 2) {
            NSTableCellView *keyView = [self.keyValueTableView viewAtColumn:0 row:row makeIfNecessary:NO];
            NSTextField *keyTextField = (NSTextField*)[keyView viewWithTag:1];
            [item setObject:textField.stringValue forKey:keyTextField.stringValue];
            
            if ([keyTextField.stringValue isEqualToString:@"Name"]) {
                NSInteger oldSeletedRow = self.itemTableView.selectedRow;
                [self.itemTableView reloadData];
                [self.itemTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:oldSeletedRow] byExtendingSelection:NO];
            }
        }
    }
}

@end
