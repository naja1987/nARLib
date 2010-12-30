//
//  exampleAppDelegate.h
//  example
//
//  Created by Naja von Schmude on 30.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARLocatingService.h"

@class ExampleViewController;

@interface ExampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ExampleViewController *viewController;
	
	UIDevice *device;
	NSNotificationCenter *notificationCenter;
	
	ARLocatingService *locationService;
	
	BOOL radarPosition;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ExampleViewController *viewController;

- (void)deviceOrientationChanged:(NSNotification *)notification;
- (void) locationChanged:(NSNotification *) notification;
- (void) headingChanged:(NSNotification *) notification;
- (void) locationErrorReceived:(NSNotification*) notification;

@end

