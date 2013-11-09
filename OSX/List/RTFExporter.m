//
//  RTFExporter.m
//  List
//
//  Created by 朱 曦炽 on 13-11-9.
//  Copyright (c) 2013年 Mirroon. All rights reserved.
//

#import "RTFExporter.h"

@implementation RTFExporter
+ (NSData*)RTFFormat
{
    NSString *stringWithImage = [NSString stringWithFormat:@"This is a test!\n%c",NSAttachmentCharacter];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:stringWithImage];
    
    NSImage *image = [NSImage imageNamed:@"image"];
    NSTextAttachmentCell *attachmentCell =[[NSTextAttachmentCell alloc] initImageCell:image];
    NSTextAttachment *attachment =[[NSTextAttachment alloc] init];
    [attachment setAttachmentCell: attachmentCell ];
    
    NSAttributedString *imageAttachmentAttributedString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    [attriString appendAttributedString:imageAttachmentAttributedString];
    
    return [attriString RTFFromRange:NSMakeRange(0, attriString.length) documentAttributes:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType}];
}
@end
