#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    CGRect rect = CGRectMake(0, 0, 600, 800);
    
    NSMutableDictionary* auxInfo = [NSMutableDictionary dictionary];
	[ auxInfo setObject:@"Zhu Xi Chi (kilik52@outlook.com)" forKey: (id)kCGPDFContextAuthor ];
	[ auxInfo setObject:@"xmslook" forKey: (id)kCGPDFContextCreator ];
    
    CFStringRef urlStr = CFURLGetString(url);
	CFRetain(urlStr);
	
	[ auxInfo setObject:(__bridge NSString*)urlStr forKey: (id)kCGPDFContextTitle ];
    
    
    CGContextRef pdfContext = QLPreviewRequestCreatePDFContext(preview, &rect, (__bridge CFDictionaryRef)auxInfo, NULL);
    if (pdfContext) {
        CGPDFContextBeginPage(pdfContext, NULL);
       
        NSGraphicsContext* context = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *)pdfContext flipped:YES];
        
        if (context) {
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:context];
            
            NSAffineTransform* xform = [NSAffineTransform transform];
            [xform translateXBy:0.0 yBy:800];
            [xform scaleXBy:1.0 yBy:-1.0];
            [xform concat];
            
            [context saveGraphicsState];
            NSRect nameRect = NSMakeRect(10.0,
                                         10.0,
                                         600,
                                         80);
            NSMutableAttributedString* nameDrawable = [[NSMutableAttributedString alloc]
                                                       initWithString: @"Title"];
            
            NSRange range = NSMakeRange(0,[nameDrawable length]);
            [nameDrawable addAttribute: NSFontAttributeName
                                 value: [NSFont userFontOfSize:20.0]
                                 range: range];
            [nameDrawable applyFontTraits:NSBoldFontMask
                                    range:NSMakeRange(0, [nameDrawable length])];
            [nameDrawable addAttribute: NSForegroundColorAttributeName
                                 value: [NSColor blackColor]
                                 range:range];
            
            [nameDrawable drawInRect: nameRect];
            [context restoreGraphicsState];
            
            
            [NSGraphicsContext restoreGraphicsState];
        }
        
        CGPDFContextEndPage(pdfContext);
        CGPDFContextBeginPage(pdfContext, NULL);
        CGPDFContextEndPage(pdfContext);
        CGPDFContextBeginPage(pdfContext, NULL);
        CGPDFContextEndPage(pdfContext);
        QLPreviewRequestFlushContext(preview, pdfContext);
    }
    CFRelease(pdfContext);
    CFRelease(urlStr);

    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
