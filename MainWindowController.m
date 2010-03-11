//
//  MainWindowController.m
//  Image Recognition
//
//  Created by Jean-Louis on 2010-01-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainWindowController.h"
#import "raw_drawing.h"
#import "hip_calculus.h"

#define GRIDSIZE		70
#define IMAGESIZE		400

@implementation MainWindowController

-(void)addFeaturePointX:(int)x Y:(int)y teta:(int)teta{
	NSManagedObject *afeaturepoint = [self fetchFeaturePointX:x Y:y teta:teta];
	
	if(afeaturepoint == nil){
		afeaturepoint = (NSManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:@"FeaturePoint" inManagedObjectContext:[self managedObjectContext]];
		[afeaturepoint setValue:[NSNumber numberWithInt:x] forKey:@"x"];
		[afeaturepoint setValue:[NSNumber numberWithInt:y] forKey:@"y"];
		[afeaturepoint setValue:[NSNumber numberWithInt:teta] forKey:@"teta"];
		NSManagedObject *asamplegrid = (NSManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:@"SampleGrid" inManagedObjectContext:[self managedObjectContext]];
		[asamplegrid setValue:afeaturepoint forKey:@"featurePoint"];
		NSMutableArray *histogramList = [[NSMutableArray alloc] initWithCapacity:64];
		for(int i = 0; i < 64; i++){
			NSManagedObject *ahistogram = (NSManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:@"Histogram" inManagedObjectContext:[self managedObjectContext]];
			[ahistogram setValue:asamplegrid forKey:@"sampleGrid"];
			[ahistogram setValue:[NSNumber numberWithInt:i] forKey:@"index"];
			[histogramList addObject:ahistogram];
		}
		[asamplegrid setValue:[NSSet setWithArray:histogramList] forKey:@"histograms"];
		[afeaturepoint setValue:asamplegrid forKey:@"sampleGrid"];
	}
	int n = [(NSNumber *)[afeaturepoint valueForKey:@"number"] intValue] + 1;
	[afeaturepoint setValue:[NSNumber numberWithInt:n] forKey:@"number"];
	NSSet *histograms = [[afeaturepoint valueForKey:@"sampleGrid"] valueForKey:@"histograms"];
	//NSLog(@"%@", histograms);
	for(NSManagedObject *histogram in histograms){
		//NSLog(@"%@", [histogram valueForKey:@"index"]);
	}
	//NSLog(@"Size :%d", [histograms count]);
}

-(NSManagedObject *)fetchFeaturePointX:(int)x Y:(int)y teta:(int)teta{
	NSString *entityName = @"FeaturePoint";
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(x BETWEEN { %d , %d }) AND (y BETWEEN { %d , %d }) AND (teta BETWEEN { %d , %d })", x-1, x+1, y-1, y+1, teta-5, teta+5];
	NSString *sortKey = @"number";
	BOOL sortAscending = NO;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	[request setEntity:entity];
	[request setPredicate:predicate];
	[request setFetchLimit:1];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	
	NSError *error;
	
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	NSManagedObject *result = nil;
	
	for(NSManagedObject *object in mutableFetchResults){
		result = object;
	}
	[request release];
	
	return result;
}

-(void)printDatabase{
	NSString *entityName = @"FeaturePoint";
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	[request setEntity:entity];
	[request setFetchLimit:0];
	
	NSString *sortKey = @"number";
	BOOL sortAscending = NO;
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	NSError *error;
	
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	int i = 0;
	for(NSManagedObject *object in mutableFetchResults){
		if(i<10){
			NSPoint origin = {[[object valueForKey:@"x"] intValue]-5,[[object valueForKey:@"y"] intValue]-5};
			NSSize size = {10, 10};
			NSRect rect = {origin, size};
			NSImage *square = [NSImage imageNamed:@"square.jpg"];
			NSImageView *squareView = [[NSImageView alloc] initWithFrame:rect];
			[squareView setImage:square];
			[ghostView addSubview:squareView];
			[square release];
			[squareView release];
			i++;
		}
		NSLog(@"%@", object);

	}
	NSLog(@"Number of entries: %d", [mutableFetchResults count]);
	[request release];
}

- (IBAction)start:(id)sender{
	
	indexX = 0;
	indexY = 0;
	NSImage * image    = [ghostView image];
	NSData  * tiffData = [image TIFFRepresentation];
	NSBitmapImageRep * bitmap;
	bitmap = [NSBitmapImageRep imageRepWithData:tiffData];
	
	referenceImage = [[CIImage alloc] initWithBitmapImageRep:bitmap];
	
	if(!mCaptureSession){
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
	}
	// Start capturing
	[mCaptureSession startRunning];
	
	
}

- (IBAction)stop:(id)sender{
	
	[mCaptureSession stopRunning];
	[self printDatabase];
}
-(xyz)transformXYZ:(xyz)input with:(CATransform3D)t{
	float dx = input.x;
	float dy = input.y;
	float dz = input.z;
	
	float fx = t.m11 * dx + t.m12*dy + t.m13 * dz + t.m14;
	float fy = t.m21 * dx + t.m22*dy + t.m23 * dz + t.m24;
	float fz = t.m31 * dx + t.m32*dy + t.m33 * dz + t.m34;
	float fw = t.m41 * dx + t.m42*dy + t.m43 * dz + t.m44;
	
	xyz result;
	result.x = fx/fw;
	result.y = fy/fw;
	result.z = fz/fw;
	return result;
}

-(xyz)findZforXY:(xyz)input fromA:(xyz)pointA B:(xyz)pointB C:(xyz)pointC{
	
	float a = input.x - pointA.x;
	float b = input.y - pointA.y;
	//float c = input.z - pointA.z;
	float d = pointB.x - pointA.x;
	float e = pointB.y - pointA.y;
	float f = pointB.z - pointA.z;
	float g = pointC.x - pointA.x;
	float h = pointC.y - pointA.y;
	float i = pointC.z - pointA.z;
	
	
	float z = pointA.z + (a*e*i+b*f*g-a*f*h-b*d*i)/(e*g-d*h);
	xyz result = {input.x, input.y, z};
	return result;
}


- (CIImage *)view:(QTCaptureView *)view willDisplayImage:(CIImage *)image{
	
	CIImage *ghostbusters = referenceImage;
	CIImage *outputImage = image;
	
	CIFilter *filter = [CIFilter filterWithName:@"CIPerspectiveTransform"];
	[filter setDefaults];
	[filter setValue:ghostbusters forKey:@"inputImage"];
	
	CATransform3D t = CATransform3DIdentity;
	t = CATransform3DRotate(t, -M_PI/4 + (indexX*M_PI/20), 1.0, 0.0, 0.0);
	t = CATransform3DRotate(t, -M_PI/4 + (indexY*M_PI/20), 0.0, 1.0, 0.0);
	
	upLeft.x = -IMAGESIZE/2;
	upLeft.y = IMAGESIZE/2;
	upLeft.z = 0;
	
	upRight.x = IMAGESIZE/2;
	upRight.y = IMAGESIZE/2;
	upRight.z = 0;
	
	downLeft.x = -IMAGESIZE/2;
	downLeft.y = -IMAGESIZE/2;
	downLeft.z = 0;
	
	downRight.x = IMAGESIZE/2;
	downRight.y = -IMAGESIZE/2;
	downRight.z = 0;
	
	upLeft = [self transformXYZ:upLeft with:t];
	upRight = [self transformXYZ:upRight with:t];
	downLeft = [self transformXYZ:downLeft with:t];
	downRight = [self transformXYZ:downRight with:t];
	
	t = CATransform3DIdentity;
	t = CATransform3DRotate(t, M_PI/4 - (indexY*M_PI/20), 0.0, 1.0, 0.0);
	t = CATransform3DRotate(t, M_PI/4 - (indexX*M_PI/20), 1.0, 0.0, 0.0);
	
	inverseTransform = t;
	
	[filter setValue:[CIVector vectorWithX:IMAGESIZE/2 + upLeft.x
										 Y:IMAGESIZE/2 + upLeft.y
					  ] forKey:@"inputTopLeft"];
	
	[filter setValue:[CIVector vectorWithX:IMAGESIZE/2 + upRight.x
										 Y:IMAGESIZE/2 + upRight.y
					  ] forKey:@"inputTopRight"];
	
	[filter setValue:[CIVector vectorWithX:IMAGESIZE/2 + downLeft.x
										 Y:IMAGESIZE/2 + downLeft.y
					  ] forKey:@"inputBottomLeft"];
	
	[filter setValue:[CIVector vectorWithX:IMAGESIZE/2 + downRight.x
										 Y:IMAGESIZE/2 + downRight.y
					  ] forKey:@"inputBottomRight"];
	
	CIImage *perspective = [filter valueForKey:@"outputImage"];
	
	CIFilter *filter2 = [CIFilter filterWithName:@"CIGaussianBlur"];
	[filter2 setDefaults];
	[filter2 setValue:perspective forKey:@"inputImage"];
	[filter2 setValue:[NSNumber numberWithFloat:(3 * (float)random()/RAND_MAX)] forKey:@"inputRadius"];
	outputImage = [filter2 valueForKey:@"outputImage"];
	outputImage = [self processImage:outputImage];
	
	indexX++;
	if(indexX>10){
		indexX = 0;
		indexY++;
		if(indexY >10){
			indexY = 0;
			[mCaptureSession stopRunning];
			[self printDatabase];
		}
	}
	return outputImage;
	//return outputImage;
}

- (CIImage *)processImage:(CIImage *)image{
	
	NSBitmapImageRep* rep = [[[NSBitmapImageRep alloc] initWithCIImage:image] autorelease];
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
	// example is represented by 1 byte of grey
	bitmapBytesPerRow   = (pixelsWide);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericGray);
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
									 kCGImageAlphaNone);
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
		int numcorners;
		xy* cornersList;
		xy* anglesList;
		xy sampleGrid[64];
		cornersList = fast9_detect_nonmax(data, pixelsWide, pixelsHigh, bitmapBytesPerRow, 10, &numcorners);
		anglesList = fast9_angles(data, bitmapBytesPerRow, cornersList, numcorners);
		for(int i = 0; i<numcorners; i++){
			//data[cornersList[i].x + bitmapBytesPerRow * cornersList[i].y ] = 255;
			
			/*
			 if(	(cornersList[i].x + anglesList[i].x > 0) &&
			 (cornersList[i].x + anglesList[i].x < pixelsWide) &&
			 (cornersList[i].y + anglesList[i].y > 0) &&
			 (cornersList[i].y + anglesList[i].y < pixelsHigh)){
			 lineBresenham(cornersList[i].x, cornersList[i].y, cornersList[i].x + anglesList[i].x,  cornersList[i].y + anglesList[i].y, data, bitmapBytesPerRow);
			 }
			 */
			if(	(cornersList[i].x - 12 > 0) &&
			   (cornersList[i].x + 12 < pixelsWide) &&
			   (cornersList[i].y - 12 > 0) &&
			   (cornersList[i].y + 12 < pixelsHigh)){
				
				NSMutableArray *sampleValues = [[NSMutableArray alloc] initWithCapacity:64];
				setRotatedSampleGrid(sampleGrid, anglesList[i]);
				for(int k =0; k<64; k++){
					int index = sampleGrid[k].x + cornersList[i].x + bitmapBytesPerRow*(sampleGrid[k].y + cornersList[i].y);
					[sampleValues addObject:[NSNumber numberWithInt:data[index]]];
					data[index] = 255;
				}
				
				xyz position = {cornersList[i].x - IMAGESIZE/2, cornersList[i].y - IMAGESIZE/2, 0};
				position = [self findZforXY:position fromA:upLeft B:upRight C:downLeft];
				xyz realPosition = [self transformXYZ:position with:inverseTransform];
				
				int xvalue = (int)realPosition.x + IMAGESIZE/2;
				int yvalue = (int)realPosition.y + IMAGESIZE/2;
				if(xvalue > 0 && yvalue > 0 && xvalue<IMAGESIZE && yvalue < IMAGESIZE){
					//[self addFeaturePointX:xvalue Y:yvalue teta:getAngle(anglesList[i])];
					[self addFeaturePointX:xvalue Y:yvalue teta:0];
				}
				//NSLog(@"%@",sampleValues);
				[sampleValues release];
				
			}
		}
		
		free(cornersList);
		free(anglesList);
		
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
}

/**
 Returns the support folder for the application, used to store the Core Data
 store file.  This code uses a folder named "CoreData_Test" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"CoreData_Test"];
}

/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The folder for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"CoreData_Test.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    
	
    return persistentStoreCoordinator;
}


/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

-(void)dealloc{
	[mCaptureSession release];
	[mCaptureVideoDeviceInput release];
	[mCaptureView release];
	[ghostView release];
	
	[managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
	[super dealloc];
}

@end
