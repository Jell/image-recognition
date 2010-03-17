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

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
-(void)addFeaturePointX:(int)x Y:(int)y teta:(int)teta samples:(float *)samples;
-(NSManagedObject *)fetchFeaturePointX:(int)x Y:(int)y teta:(int)teta;
-(void)printDatabase;
- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)train:(id)sender;
- (CIImage *)processImage:(CIImage *)image;
- (void)processImageTraining:(CIImage *)image;
- (xyz)findZforXY:(xyz)input fromA:(xyz)pointA B:(xyz)pointB C:(xyz)pointC;
-(void)genertateHipList;
- (void)finalize;

@end
