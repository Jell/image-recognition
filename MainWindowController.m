//
//  MainWindowController.m
//  Image Recognition
//
//  Created by Jean-Louis on 2010-01-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainWindowController.h"


@implementation MainWindowController


- (IBAction)start:(id)sender{

	mPSO = [[PSO alloc] init];
	[mPSO initSwarm];
	
	[mCaptureView setDelegate:self];
	
	mCaptureSession = [[QTCaptureSession alloc] init];
	
	BOOL success = NO;
	NSError *error;
	
	// Find a video device  
	
	QTCaptureDevice *videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
	success = [videoDevice open:&error];
	
	mCaptureVideoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:videoDevice];
	success = [mCaptureSession addInput:mCaptureVideoDeviceInput error:&error];
	
	[mCaptureView setCaptureSession:mCaptureSession];
	
	// Start capturing!
	[mCaptureSession startRunning];
	

}

- (IBAction)stop:(id)sender{
	[mCaptureSession stopRunning];
}

- (CIImage *)view:(QTCaptureView *)view willDisplayImage:(CIImage *)image{
	CGRect rect;
	CGPoint origin;
	origin.x = 0;
	origin.y = 0;
	
	CGSize size;
	size.width = 460;
	size.height = 320;
	
	rect.origin = origin;
	rect.size = size;
	
	CIImage *imageCrop = [[image imageByApplyingTransform:CGAffineTransformMakeScale(0.4, 0.4)] imageByCroppingToRect:rect];
	NSBitmapImageRep* rep = [[[NSBitmapImageRep alloc] initWithCIImage:imageCrop] autorelease];
	CGImageRef inImage = rep.CGImage;
	
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedFirst);
	if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
		return nil;
	}
	
	CGRect rect2 = {{0,0},{pixelsWide,pixelsHigh}}; 
	
	// Draw the image to the bitmap context. Once we draw, the memory
	// allocated for the context for rendering will then contain the
	// raw image data in the specified color space.
	CGContextDrawImage(context, rect2, inImage); 
	
	// Now we can get a pointer to the image data associated with the bitmap
	// context.
	unsigned char* data = CGBitmapContextGetData(context);
	
	if (data != NULL) {
		[mPSO performIteration:data];
		
		for(int i = 0; i<SWARMSIZE; i++){
			int offset = 4*((int) mPSO->particleArray[i].mX) + bitmapBytesPerRow * ((int) mPSO->particleArray[i].mY);
			if((offset < bitmapByteCount - 4 - 10*4 - 10*bitmapBytesPerRow) && (offset > 0)){
				for(int k = 0; k<10; k++){
					for(int l = 0; l<10; l++){
						//alpha
						data[offset + 4*k + bitmapBytesPerRow*l] = 255;
						//red
						data[offset+1 + 4*k + bitmapBytesPerRow*l] = 0;
						//green
						data[offset+2 + 4*k + bitmapBytesPerRow*l] = 255;
						//blue
						data[offset+3 + 4*k + bitmapBytesPerRow*l] = 0;
					}
				}
			}

		}
		
		int offset = 4*((int) mPSO->globalBest.mX) + bitmapBytesPerRow * ((int) mPSO->globalBest.mY);
		if((offset < bitmapByteCount - 4 - 10*4 - 10*bitmapBytesPerRow) && (offset > 0)){
			for(int k = 0; k<10; k++){
				for(int l = 0; l<10; l++){
					//alpha
					data[offset + 4*k + bitmapBytesPerRow*l] = 255;
					//red
					data[offset+1 + 4*k + bitmapBytesPerRow*l] = 255;
					//green
					data[offset+2 + 4*k + bitmapBytesPerRow*l] = 0;
					//blue
					data[offset+3 + 4*k + bitmapBytesPerRow*l] = 0;
				}
			}
		}
		

	}

	CGImageRef cgImage = CGBitmapContextCreateImage(context);
	CIImage *outImage = [CIImage imageWithCGImage:cgImage];	
	// Make sure and release colorspace before returning
	
	CGImageRelease(cgImage);
	CGColorSpaceRelease( colorSpace );
	// When finished, release the context
	CGContextRelease(context);
	// Free image data memory for the context
	if (data) { free(data); }

	return outImage;
	//return imageCrop;
}

@end
