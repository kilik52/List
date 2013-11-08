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
    /*
    // To complete your generator please implement the function GeneratePreviewForURL in GeneratePreviewForURL.c
    NSSize canvasSize = NSMakeSize(600, 800);
    
    // Preview will be drawn in a vectorized context
	// Here we create a graphics context to draw the Quick Look Preview in
    CGContextRef cgContext = QLPreviewRequestCreateContext(preview, *(CGSize *)&canvasSize, false, NULL);
    if(cgContext) {
        NSGraphicsContext* context = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *)cgContext flipped:YES];
        if(context) {
			//These two lines of code are just good safe programming...
			[NSGraphicsContext saveGraphicsState];
			[NSGraphicsContext setCurrentContext:context];
			
            // Draw here
            
            
			//This line sets the context back to what it was when we're done
			[NSGraphicsContext restoreGraphicsState];
        }
        
		// When we are done with our drawing code QLPreviewRequestFlushContext() is called to flush the context
        QLPreviewRequestFlushContext(preview, cgContext);
        
        CFRelease(cgContext);
    }
    */
    
    NSString *_content = @"This is Preview";
    
    QLPreviewRequestSetDataRepresentation(preview,(__bridge CFDataRef)[_content dataUsingEncoding:NSUTF8StringEncoding],kUTTypePlainText,NULL);
    
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
