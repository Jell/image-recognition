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

@interface MainWindowController : NSObject {
	QTCaptureSession *mCaptureSession;
	QTCaptureDeviceInput *mCaptureVideoDeviceInput;
	IBOutlet QTCaptureView *mCaptureView;
	IBOutlet NSImageView *ghostView;
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
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
-(void)addFeaturePointX:(int)x Y:(int)y teta:(int)teta;
-(NSManagedObject *)fetchFeaturePointX:(int)x Y:(int)y teta:(int)teta;
-(void)printDatabase;
- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;
- (CIImage *)processImage:(CIImage *)image;
-(xyz)findZforXY:(xyz)input fromA:(xyz)pointA B:(xyz)pointB C:(xyz)pointC;

@end
