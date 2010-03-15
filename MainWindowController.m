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

#define GRIDSIZE				70
#define IMAGESIZE				200
#define ITERATIONNUMBER			10
#define FEATUREPOINTS_NUMBER	200
@implementation MainWindowController

-(void)addFeaturePointX:(int)x Y:(int)y teta:(int)teta samples:(float *)samples{
	NSManagedObject *afeaturepoint = [self fetchFeaturePointX:x Y:y teta:teta];
	
	if(afeaturepoint == nil){
		afeaturepoint = (NSManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:@"FeaturePoint" inManagedObjectContext:[self managedObjectContext]];
		[afeaturepoint setValue:[NSNumber numberWithInt:x] forKey:@"x"];
		[afeaturepoint setValue:[NSNumber numberWithInt:y] forKey:@"y"];
		[afeaturepoint setValue:[NSNumber numberWithInt:teta] forKey:@"teta"];
		
		NSMutableArray *histogramList = [[NSMutableArray alloc] initWithCapacity:64];
		for(int i = 0; i < 64; i++){
			NSManagedObject *ahistogram = (NSManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:@"Histogram" inManagedObjectContext:[self managedObjectContext]];
			[ahistogram setValue:afeaturepoint forKey:@"featurePoint"];
			[ahistogram setValue:[NSNumber numberWithInt:i] forKey:@"index"];
			[histogramList addObject:ahistogram];
		}
		[afeaturepoint setValue:[NSSet setWithArray:histogramList] forKey:@"histograms"];
	}
	int n = [(NSNumber *)[afeaturepoint valueForKey:@"number"] intValue] + 1;
	[afeaturepoint setValue:[NSNumber numberWithInt:n] forKey:@"number"];
	NSSet *histograms = [afeaturepoint valueForKey:@"histograms"];
	//NSLog(@"%@", histograms);
	for(NSManagedObject *histogram in histograms){
		int index = [[histogram valueForKey:@"index"] intValue];
		float value = samples[index];
		NSString *key = @"Range4";
		if(value <-0.75){
			key = @"Range1";
		}else if(value >0.75){
			key = @"Range5";
		}else if(value >= -0.75 && value < -0.25){
			key = @"Range2";
		}else if(value >= -0.25 && value < 0.25){
			key = @"Range3";
		}
		
		int n = [(NSNumber *)[histogram valueForKey:key] intValue] + 1;
		[histogram setValue:[NSNumber numberWithInt:n] forKey:key];
		//NSLog(@"%@", [histogram valueForKey:@"index"]);
	}
	//NSLog(@"Size :%d", [histograms count]);
}

-(void)addHIP:(int)x Y:(int)y teta:(int)teta R1:(long long)R1 R2:(long long)R2 R3:(long long)R3 R4:(long long)R4 R5:(long long)R5{
	NSManagedObject *anHIP = (NSManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:@"HIP" inManagedObjectContext:[self managedObjectContext]];
	[anHIP setValue:[NSNumber numberWithInt:x] forKey:@"x"];
	[anHIP setValue:[NSNumber numberWithInt:y] forKey:@"y"];
	[anHIP setValue:[NSNumber numberWithInt:teta] forKey:@"teta"];
	[anHIP setValue:[NSNumber numberWithLongLong:R1] forKey:@"R1"];
	[anHIP setValue:[NSNumber numberWithLongLong:R2] forKey:@"R2"];
	[anHIP setValue:[NSNumber numberWithLongLong:R3] forKey:@"R3"];
	[anHIP setValue:[NSNumber numberWithLongLong:R4] forKey:@"R4"];
	[anHIP setValue:[NSNumber numberWithLongLong:R5] forKey:@"R5"];
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
	NSString *entityName = @"HIP";
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	[request setEntity:entity];
	[request setFetchLimit:0];
	/*
	NSString *sortKey = @"number";
	BOOL sortAscending = NO;
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	*/
	NSError *error;
	
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];

	for(NSManagedObject *object in mutableFetchResults){
			NSPoint origin = {[[object valueForKey:@"x"] intValue]*2-16,[[object valueForKey:@"y"] intValue]*2-16};
			NSSize size = {32, 32};
			NSRect rect = {origin, size};
			NSImage *square = [NSImage imageNamed:@"square.jpg"];
			NSImageView *squareView = [[NSImageView alloc] initWithFrame:rect];
			[squareView setBoundsRotation:[[object valueForKey:@"teta"] floatValue]];
			[squareView setImage:square];
			[ghostView addSubview:squareView];
			NSLog(@"%@", object);
	}
	NSLog(@"Number of entries: %d", [mutableFetchResults count]);
	[request release];
}

-(void)clearDatabase{
	NSManagedObjectContext * context = [self managedObjectContext];
	NSFetchRequest * fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:[NSEntityDescription entityForName:@"FeaturePoint" inManagedObjectContext:context]];
	NSArray * result = [context executeFetchRequest:fetch error:nil];
	for (id basket in result)
		[context deleteObject:basket];
	
	[fetch setEntity:[NSEntityDescription entityForName:@"Histogram" inManagedObjectContext:context]];
	result = [context executeFetchRequest:fetch error:nil];
	for (id object in result)
		[context deleteObject:object];
	
	[fetch setEntity:[NSEntityDescription entityForName:@"HIP" inManagedObjectContext:context]];
	result = [context executeFetchRequest:fetch error:nil];
	for (id object in result)
		[context deleteObject:object];
}

- (IBAction)start:(id)sender{
	
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

-(void)finalize{
	
	NSString *entityName = @"FeaturePoint";
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	[request setEntity:entity];
	[request setFetchLimit:FEATUREPOINTS_NUMBER];
	
	NSString *sortKey = @"number";
	BOOL sortAscending = NO;
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	NSError *error;
	
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	int size = [mutableFetchResults count];
	
	for(int i = 0; i< size; i++){
		NSManagedObject *featurepoint = [mutableFetchResults objectAtIndex:i];
		int x = [[featurepoint valueForKey:@"x"] intValue];
		int y = [[featurepoint valueForKey:@"y"] intValue];
		int teta = [[featurepoint valueForKey:@"teta"] intValue];
		// Get the histogram values
		NSSet *histograms = [featurepoint valueForKey:@"histograms"];
		
		float number = [[featurepoint valueForKey:@"number"] floatValue];
		//NSLog(@"%@", histograms);
		
		BOOL quantizedSamples[64][5];
		
		for(NSManagedObject *histogram in histograms){
			int index = [[histogram valueForKey:@"index"] intValue];
			
			for(int k = 0; k<5; k++){
				NSString *key = [NSString stringWithFormat:@"Range%d",k+1];
				float ratio = [[histogram valueForKey:key] floatValue] / number;
				quantizedSamples[index][k] = (ratio > 0.05);
			}
		}

		long long R1 = 0;
		long long R2 = 0;
		long long R3 = 0;
		long long R4 = 0;
		long long R5 = 0;
		for(int k = 0; k<64; k++){
			R1 <<= 1;
			R1 |= quantizedSamples[k][0];
			
			R2 <<= 1;
			R2 |= quantizedSamples[k][1];
			
			R3 <<= 1;
			R3 |= quantizedSamples[k][2];
			
			R4 <<= 1;
			R4 |= quantizedSamples[k][3];
			
			R5 <<= 1;
			R5 |= quantizedSamples[k][4];
		}
		[self addHIP:x Y:y teta:teta R1:R1 R2:R2 R3:R3 R4:R4 R5:R5];
	}
	[request release];
	
	[self genertateHipList];
}

-(void)genertateHipList{
	NSString *entityName = @"HIP";
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	[request setEntity:entity];
	[request setFetchLimit:0];

	NSError *error;
	
	hipList = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	[request release];
	
}

- (CIImage *)view:(QTCaptureView *)view willDisplayImage:(CIImage *)image{
	
	CIFilter *filter = [CIFilter filterWithName:@"CIPerspectiveTransform"];
	[filter setDefaults];
	[filter setValue:image forKey:@"inputImage"];
	
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
	
	[filter setValue:[CIVector vectorWithX:0
										 Y:400
					  ] forKey:@"inputTopLeft"];
	
	[filter setValue:[CIVector vectorWithX:480
										 Y:400
					  ] forKey:@"inputTopRight"];
	
	[filter setValue:[CIVector vectorWithX:0
										 Y:0
					  ] forKey:@"inputBottomLeft"];
	
	[filter setValue:[CIVector vectorWithX:480
										 Y:0
					  ] forKey:@"inputBottomRight"];
	
	CIImage *output = [filter valueForKey:@"outputImage"];
	
	return [self processImage:output];
	//return outputImage;
}

-(BOOL)testSampleGrid:(float *)sampleGrid x:(int *)x y:(int *)y teta:(int *)teta{
	long long R1 = 0;
	long long R2 = 0;
	long long R3 = 0;
	long long R4 = 0;
	long long R5 = 0;
	for(int k = 0; k<64; k++){
		R1 <<= 1;
		R1 |= (sampleGrid[k] < -0.75);
		
		R2 <<= 1;
		R2 |= (sampleGrid[k] >= -0.75 && sampleGrid[k] < -0.25);
		
		R3 <<= 1;
		R3 |= (sampleGrid[k] >= -0.25 && sampleGrid[k] < 0.25);
		
		R4 <<= 1;
		R4 |= (sampleGrid[k] >= 0.25 && sampleGrid[k] < 0.75);
		
		R5 <<= 1;
		R5 |= (sampleGrid[k] > 0.75);
	}
	
	for(NSManagedObject *object in hipList){
		long long compareR1 = [[object valueForKey:@"R1"] longLongValue];
		long long compareR2 = [[object valueForKey:@"R2"] longLongValue];
		long long compareR3 = [[object valueForKey:@"R3"] longLongValue];
		long long compareR4 = [[object valueForKey:@"R4"] longLongValue];
		long long compareR5 = [[object valueForKey:@"R5"] longLongValue];
		
		int result = bitcount((R1 & compareR1) | (R2 & compareR2) | (R3 & compareR3) | (R4 & compareR4) | (R5 & compareR5));
		if(result >=62){
			*x =  [[object valueForKey:@"x"] intValue];
			*y =  [[object valueForKey:@"y"] intValue];
			*teta = [[object valueForKey:@"teta"] intValue];
			return YES;
		}
		
	}
	return NO;
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
		cornersList = fast9_detect_nonmax(data, pixelsWide, pixelsHigh, bitmapBytesPerRow, 20, &numcorners);
		anglesList = fast9_angles(data, bitmapBytesPerRow, cornersList, numcorners);
		
		NSMutableArray *arrayOfBins = [[NSMutableArray alloc] initWithCapacity:16];
		
		for(int i = 0; i< 16; i++){
			NSMutableArray *histogram = [[NSMutableArray alloc] init];
			[arrayOfBins addObject:histogram];
		}
		
		for(int i = 0; i<numcorners; i++){

			if(	(cornersList[i].x - 12 > 0) &&
			   (cornersList[i].x + 12 < pixelsWide) &&
			   (cornersList[i].y - 12 > 0) &&
			   (cornersList[i].y + 12 < pixelsHigh)){
				
				
				float sampleValues[64];
				setRotatedSampleGrid(sampleGrid, anglesList[i]);
				for(int k =0; k<64; k++){
					int index = sampleGrid[k].x + cornersList[i].x + bitmapBytesPerRow*(sampleGrid[k].y + cornersList[i].y);
					sampleValues[k] = data[index];
				}
				
				equalize(sampleValues, 64);
				
				int matchX = 0;
				int matchY = 0;
				int matchTeta = 0;
				
				if([self testSampleGrid:sampleValues x:&matchX y:&matchY teta:&matchTeta]){
					/*
					for(int k =0; k<64; k++){
						int index = sampleGrid[k].x + cornersList[i].x + bitmapBytesPerRow*(sampleGrid[k].y + cornersList[i].y);
						data[index] = 255;
					}*/
					
					int angleBin = (360 + getAngle(anglesList[i]) - matchTeta)%360;
					
					int n = 0;
					for(NSMutableArray *histogram in arrayOfBins){
						if(angleBin > 22.5 * n && angleBin < 22.5 *n + 30){
							[histogram addObject:[NSNumber numberWithInt:i]];
						}
						n++;
					}
				}
			}
		}
		
		int bestBinSize = 0;
		NSMutableArray *bestBin = nil;
		for(NSMutableArray *histogram in arrayOfBins){
			int histogramSize = [histogram count];
			if(histogramSize > 5 && histogramSize > bestBinSize){
				bestBinSize = histogramSize;
				bestBin = histogram;
			}
		}
		
		for(NSNumber *index in bestBin){
			for(int i = -5; i<5; i++){
				for(int j = -5; j<5; j++){
					int dataIndex = i + cornersList[[index intValue]].x + bitmapBytesPerRow*(j + cornersList[[index intValue]].y);
					data[dataIndex] = 255;
				}
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

- (IBAction)train:(id)sender{
	if(!opQueue){
		opQueue = [[NSOperationQueue alloc] init];
	}
	NSLog(@"Number of views:%d", [[ghostView subviews] count]);
	[[ghostView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
	
	[self clearDatabase];
	[self printDatabase];
	indexX = 0;
	indexY = 0;
	NSImage * image    = [ghostView image];
	NSData  * tiffData = [image TIFFRepresentation];
	NSBitmapImageRep * bitmap;
	bitmap = [NSBitmapImageRep imageRepWithData:tiffData];
	
	referenceImage = [[CIImage alloc] initWithBitmapImageRep:bitmap];
	
	NSInvocationOperation *request = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(runTraining:) object:self];
	[opQueue addOperation:request];
	[request release];
	
}

- (void)processImageTraining:(CIImage *)image{
	
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
		return;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return;
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
		return;
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
		cornersList = fast9_detect_nonmax(data, pixelsWide, pixelsHigh, bitmapBytesPerRow, 20, &numcorners);
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
				
				
				float x = (float)cornersList[i].x;
				float y = (float)cornersList[i].y;
				float offsetX = (float)pixelsWide / 2;
				float offsetY = (float)pixelsHigh / 2;
				
				xyz center = {0.0,0.0,0.0};
				xyz position = {x - offsetX, offsetY - y, 0};
				xyz anglePosition = {position.x + (float)anglesList[i].x, position.y - (float)anglesList[i].y, 0};
				
				position = [self findZforXY:position fromA:center B:downRight C:upRight];
				anglePosition = [self findZforXY:anglePosition fromA:center B:downRight C:upRight];
				
				
				xyz realPosition = [self transformXYZ:position with:inverseTransform];
				xyz angleRealPosition = [self transformXYZ:anglePosition with:inverseTransform];
				
				xy angle = {angleRealPosition.x - realPosition.x, angleRealPosition.y - realPosition.y};
				
				int xvalue = ((int)realPosition.x + IMAGESIZE/2);
				int yvalue = ((int)realPosition.y + IMAGESIZE/2);
				
				if(xvalue > 20 && yvalue > 20 && xvalue<IMAGESIZE-20 && yvalue < IMAGESIZE-20){
					float sampleValues[64];
					setRotatedSampleGrid(sampleGrid, anglesList[i]);
					for(int k =0; k<64; k++){
						int index = sampleGrid[k].x + cornersList[i].x + bitmapBytesPerRow*(sampleGrid[k].y + cornersList[i].y);
						sampleValues[k] = data[index];
						data[index] = 255;
					}
					
					equalize(sampleValues, 64);
					//[self addFeaturePointX:xvalue Y:yvalue teta:0];
					[self addFeaturePointX:xvalue Y:yvalue teta:getAngle(angle) samples:sampleValues];
				}
			}
		}
		
		free(cornersList);
		free(anglesList);
		
	}

	CGColorSpaceRelease( colorSpace );
	// When finished, release the context
	CGContextRelease(context);
	// Free image data memory for the context
	if (data) { free(data); }
}

-(void)updateProgress:(id)object{
	NSNumber *value = (NSNumber *)object;
	[mProgressIndicator setMinValue:0];
	[mProgressIndicator setMaxValue:100.0];
	[mProgressIndicator setDoubleValue:[value doubleValue]];
}
-(void)runTraining:(id)object{

	for(indexX = 0; indexX<ITERATIONNUMBER; indexX++){
		for(indexY = 0; indexY < ITERATIONNUMBER; indexY++){
		NSNumber *progressValue = [NSNumber numberWithDouble:100*((double)indexX*ITERATIONNUMBER + (double)(indexY+1))/(ITERATIONNUMBER*ITERATIONNUMBER)];
		[self performSelectorOnMainThread:@selector(updateProgress:) withObject:progressValue waitUntilDone:YES];

	CIImage *ghostbusters = referenceImage;
	
	CIFilter *filter = [CIFilter filterWithName:@"CIPerspectiveTransform"];
	[filter setDefaults];
	[filter setValue:ghostbusters forKey:@"inputImage"];
	
	CATransform3D t = CATransform3DIdentity;
	t = CATransform3DRotate(t, -M_PI/4 + (indexX*M_PI/(2*ITERATIONNUMBER)), 1.0, 0.0, 0.0);
	t = CATransform3DRotate(t, -M_PI/4 + (indexY*M_PI/(2*ITERATIONNUMBER)), 0.0, 1.0, 0.0);
	
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
	t = CATransform3DRotate(t, M_PI/4 - (indexY*M_PI/(2*ITERATIONNUMBER)), 0.0, 1.0, 0.0);
	t = CATransform3DRotate(t, M_PI/4 - (indexX*M_PI/(2*ITERATIONNUMBER)), 1.0, 0.0, 0.0);
	
	inverseTransform = t;
	
	[filter setValue:[CIVector vectorWithX:upLeft.x
										 Y:upLeft.y
					  ] forKey:@"inputTopLeft"];
	
	[filter setValue:[CIVector vectorWithX:upRight.x
										 Y:upRight.y
					  ] forKey:@"inputTopRight"];
	
	[filter setValue:[CIVector vectorWithX:downLeft.x
										 Y:downLeft.y
					  ] forKey:@"inputBottomLeft"];
	
	[filter setValue:[CIVector vectorWithX:downRight.x
										 Y:downRight.y
					  ] forKey:@"inputBottomRight"];
	
	CIImage *perspective = [filter valueForKey:@"outputImage"];
	
	CIFilter *filter2 = [CIFilter filterWithName:@"CIGaussianBlur"];
	[filter2 setDefaults];
	[filter2 setValue:perspective forKey:@"inputImage"];
	[filter2 setValue:[NSNumber numberWithFloat:(0.5 + 1.5 * (float)random()/RAND_MAX)] forKey:@"inputRadius"];
	CIImage *outputImage = [filter2 valueForKey:@"outputImage"];
	[self processImageTraining:outputImage];
	
		}
	}
	[self finalize];
	[self printDatabase];

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
