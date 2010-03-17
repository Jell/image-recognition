//
//  MainWindowController.h
//  Image Recognition
//
//  Created by Jean-Louis on 2010-01-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MainWindow.h"
#import "fast.h"
#import "homest.h"

@interface MainWindowController : NSObject {
	QTCaptureSession *mCaptureSession;
	QTCaptureDeviceInput *mCaptureVideoDeviceInput;
	NSOperationQueue *opQueue;
	IBOutlet QTCaptureView *mCaptureView;
	IBOutlet NSImageView *ghostView;
	IBOutlet NSProgressIndicator *mProgressIndicator;
	int indexX;
	int indexY;
	CIImage * referenceImage;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	CATransform3D inverseTransform;
	
	xyz upLeft;
	xyz upRight;
	xyz downLeft;
	xyz downRight;
	
	NSArray *hipList;
	
	//-----------------Command Outlets
	IBOutlet NSSlider *realtimeContrast;
	IBOutlet NSSlider *realtimeThreshold;
	IBOutlet NSSlider *realtimeInlinerRatio;
	IBOutlet NSSlider *realtimeBlur;
	IBOutlet NSMatrix *realtimeHomographyType;
	
	IBOutlet NSSlider *trainingContrast;
	IBOutlet NSTextField *trainingFeatureNumber;
	IBOutlet NSTextField *trainingViewNumber;
	IBOutlet NSTextField *trainingImageSize;
	
	IBOutlet NSButton *displayCorners;
	IBOutlet NSButton *displayAllMatches;
	IBOutlet NSButton *displayViewBin;
	IBOutlet NSButton *displayHomography;

	
	//-----------------Param Values
	float BLURVALUE;
	int IMAGESIZE;
	int ITERATIONNUMBER;
	int FEATUREPOINTS_NUMBER;
	int MINIMUM_CONTRAST_REALTIME;
	int MINIMUM_CONTRAST_TRAINING;
	int ACCEPT_THRESHOLD;
	float INL_PCENT;
}


//-------------- Realtime --------------

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;
- (BOOL)testSampleGrid:(float *)sampleGrid x:(int *)x y:(int *)y teta:(int *)teta;
- (CIImage *)processImage:(CIImage *)image;

//-------------- Training --------------

- (IBAction)train:(id)sender;
- (void)processImageTraining:(CIImage *)image;
- (void)finalize;
- (void)genertateHipList;
- (xyz)transformXYZ:(xyz)input with:(CATransform3D)t;
- (xyz)findZforXY:(xyz)input fromA:(xyz)pointA B:(xyz)pointB C:(xyz)pointC;

//-------------- Database Stuff --------------

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
- (void)addFeaturePointX:(int)x Y:(int)y teta:(int)teta samples:(float *)samples;
- (NSManagedObject *)fetchFeaturePointX:(int)x Y:(int)y teta:(int)teta;
- (void)addHIP:(int)x Y:(int)y teta:(int)teta R1:(long long)R1 R2:(long long)R2 R3:(long long)R3 R4:(long long)R4 R5:(long long)R5;
- (void)printDatabase;
- (void)clearDatabase;


@end
