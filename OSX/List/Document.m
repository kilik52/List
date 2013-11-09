//
//  Document.m
//  List
//
//  Created by 朱 曦炽 on 13-11-5.
//  Copyright (c) 2013年 Mirroon. All rights reserved.
//

#import "Document.h"
#import "NSImage+Additions.h"
#import "RTFExporter.h"

// More keys, and a version number, which are just used in Sketch's property-list-based file format.
static NSString *DocumentVersionKey = @"version";
static NSInteger DocumentCurrentVersion = 1;

@interface Document ()
// Model
@property (nonatomic,strong) NSMutableArray *items; // The value only contains two type: text & image list
@property (nonatomic, strong) NSMutableArray *keys;
@end

@implementation Document

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        self.items = [[NSMutableArray alloc] init];
        
        // the first default key is 'Name'
        self.keys = [[NSMutableArray alloc] initWithObjects:@"Name", nil];
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

#pragma mark - Save & Load Document
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    if ([typeName isEqualToString:@"public.rtf"]) {
        return [RTFExporter RTFFormat];
    }
    else if([typeName isEqualToString:@"com.adobe.pdf"]) {
        return nil;
    }
    else {
        // Convert the contents of the document to a property list and then flatten the property list.
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        
        // 1. document version
        [properties setObject:[NSNumber numberWithInteger:DocumentCurrentVersion] forKey:DocumentVersionKey];
        
        // 2. keys
        [properties setObject:self.keys forKey:@"keys"];
        
        // 3. items maybe contains image list, so we need to construct our own properties
        NSMutableArray *itemProperties = [[NSMutableArray alloc] init];
        for (NSMutableDictionary *item in self.items) {
            NSMutableDictionary *itemProperty = [[NSMutableDictionary alloc] init];
            for (NSString *key in [item allKeys]) {
                id obj = [item objectForKey:key];
                if ([obj isKindOfClass:[NSString class]]) {
                    // Text
                    [itemProperty setObject:obj forKey:key];
                }
                else if ([obj isKindOfClass:[NSArray class]]) {
                    // Image list
                    NSArray *objArray = (NSArray*)obj;
                    NSMutableArray *objProperties = [[NSMutableArray alloc] init];
                    for (NSImage *image in objArray) {
                        NSData *imageData = [image PNGRepresentation];
                        [objProperties addObject:imageData];
                    }
                    [itemProperty setObject:objProperties forKey:key];
                }
            }
            [itemProperties addObject:itemProperty];
        }
        [properties setObject:itemProperties forKey:@"items"];
        
        NSData *data = [NSPropertyListSerialization dataFromPropertyList:properties format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
        
        return data;
    }
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSMutableDictionary *properties = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListMutableContainers format:NULL errorDescription:NULL];
    if (properties) {
        // 1. document version
        NSNumber *docVersionNumber = [properties objectForKey:DocumentVersionKey];
        NSAssert([docVersionNumber intValue] == 1, @"Only Support Doc Version 1");
        
        // 2. keys
        self.keys = [properties objectForKey:@"keys"];
        
        // 3. items
        NSArray *importItems = [properties objectForKey:@"items"];
        self.items = [[NSMutableArray alloc] init];
        for (NSDictionary *importDict in importItems) {
            NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
            for (NSString *key in [importDict allKeys]) {
                id obj = [importDict objectForKey:key];
                if ([obj isKindOfClass:[NSString class]]) {
                    // Text
                    [item setObject:obj forKey:key];
                }
                else if ([obj isKindOfClass:[NSArray class]]) {
                    // Image list
                    NSArray *objArray = (NSArray*)obj;
                    NSMutableArray *imageList = [[NSMutableArray alloc] init];
                    for (NSData *importImage in objArray) {
                        NSImage *image = [[NSImage alloc] initWithData:importImage];
                        [imageList addObject:image];
                    }
                    [item setObject:imageList forKey:key];
                }
            }
            
            [self.items addObject:item];
        }
    }
    return YES;
}

#pragma mark - Print
- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError **)outError
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Print Not Implemented!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Contact kilik52@outlook.com if your want this function."];
    [alert beginSheetModalForWindow:nil modalDelegate:nil didEndSelector:nil contextInfo:nil];
    return nil;
}

#pragma mark - Model Methods
- (BOOL)checkKeyUniqueness:(NSString*)addingKey
{
    for (NSString *key in self.keys) {
        if ([addingKey isEqualToString:key]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - View Methods
- (IBAction)addItem:(id)sender {
    static int i = 1;
    NSString *newItemName = [NSString stringWithFormat:@"Item%02d",i++];
    
    NSString *firstKey = [self.keys objectAtIndex:0];
    NSMutableDictionary *itemDict = [[NSMutableDictionary alloc] initWithDictionary:@{firstKey:newItemName}];
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

- (IBAction)addKey:(id)sender {
    static int i=1;
    NSString *key = [NSString stringWithFormat:@"Key%02d",i++];
    [self.keys addObject:key];
    
    // 3. Insert new row in the table view
    NSInteger newRowIndex = self.keys.count-1;
    [self.keyValueTableView beginUpdates];
    [self.keyValueTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:newRowIndex] withAnimation:NSTableViewAnimationEffectGap];
    [self.keyValueTableView endUpdates];
    
    // 4. Select the new bug and scroll to make sure it's visible
    [self.keyValueTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newRowIndex] byExtendingSelection:NO];
    [self.keyValueTableView scrollRowToVisible:newRowIndex];
}

- (IBAction)removeKey:(id)sender {
    return; // it's quite dangrous
    
    if (self.keyValueTableView.selectedRow >= 0 && self.keyValueTableView.selectedRow < self.keys.count) {
        NSInteger selectedRow = self.keyValueTableView.selectedRow;
        [self.keys removeObjectAtIndex:selectedRow];
        // 3. Remove the selected row from the table view.
        [self.keyValueTableView beginUpdates];
        [self.keyValueTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedRow] withAnimation:NSTableViewAnimationSlideRight];
        [self.keyValueTableView endUpdates];
        
        // 4. Select the new row
        if (selectedRow >= self.keys.count) {
            selectedRow = self.keys.count - 1;
        }
        [self.keyValueTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
        [self.keyValueTableView scrollRowToVisible:selectedRow];
    }
}

#pragma mark - NSTableViewDelegate
- (NSMutableDictionary*)selectedItem
{
    if (self.itemTableView.selectedRow >= 0 && self.itemTableView.selectedRow < self.items.count) {
        return [self.items objectAtIndex:self.itemTableView.selectedRow];
    }
    return nil;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    // Since this is a single-column table view, this would not be necessary.
    // But it's a good practice to do it in order by remember it when a table is multicolumn.
    if( [tableColumn.identifier isEqualToString:@"ItemColumn"] )
    {
        NSMutableDictionary *item = [self.items objectAtIndex:row];
        NSString *firstKey = [self.keys objectAtIndex:0];
        cellView.textField.stringValue = [item objectForKey:firstKey];
        return cellView;
    }
    else if( [tableColumn.identifier isEqualToString:@"KeyColumn"] )
    {
        NSString *key = [self.keys objectAtIndex:row];
        cellView.textField.stringValue = key;
        
        return cellView;
    }
    else if( [tableColumn.identifier isEqualToString:@"ValueColumn"] )
    {
        NSMutableDictionary *item = [self selectedItem];
        NSString *key = [self.keys objectAtIndex:row];
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
        return [self.keys count];
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
            NSString *newKey = textField.stringValue;
            NSString *oldKey = [self.keys objectAtIndex:row];
            if (![oldKey isEqualToString:newKey]) {
                if ([self checkKeyUniqueness:newKey]) {
                    [self.keys replaceObjectAtIndex:row withObject:textField.stringValue];
                    
                    for (NSMutableDictionary *dict in self.items) {
                        if ([dict objectForKey:oldKey]) {
                            [dict setObject:[dict objectForKey:oldKey] forKey:newKey];
                            [dict removeObjectForKey:oldKey];
                        }
                    }
                }
                else {
                    NSLog(@"Duplicated Key");
                    [textField setStringValue:oldKey];
                }
            }
        }
        
        // change value
        if (textFieldType == 2) {
            NSTableCellView *keyView = [self.keyValueTableView viewAtColumn:0 row:row makeIfNecessary:NO];
            NSTextField *keyTextField = (NSTextField*)[keyView viewWithTag:1];
            [item setObject:textField.stringValue forKey:keyTextField.stringValue];
            
            NSString *firstKey = [self.keys objectAtIndex:0];
            if ([keyTextField.stringValue isEqualToString:firstKey]) {
                NSInteger oldSeletedRow = self.itemTableView.selectedRow;
                [self.itemTableView reloadData];
                [self.itemTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:oldSeletedRow] byExtendingSelection:NO];
            }
        }
    }
}

@end
