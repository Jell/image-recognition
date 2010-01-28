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
#import "PSO.h"

@interface MainWindowController : NSObject {
	QTCaptureSession *mCaptureSession;
	QTCaptureDeviceInput *mCaptureVideoDeviceInput;
	IBOutlet QTCaptureView *mCaptureView;
	PSO *mPSO;
}

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;

@end
