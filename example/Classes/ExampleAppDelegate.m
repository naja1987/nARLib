//
//  exampleAppDelegate.m
//  example
//
//  Created by Naja von Schmude on 30.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ExampleAppDelegate.h"
#import "ExampleViewController.h"

#import "ARGeoLocation.h"
#import "ARNotificationCenter.h"

@implementation ExampleAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	device = [UIDevice currentDevice];
	notificationCenter = [NSNotificationCenter defaultCenter];
	
	// create the location service
	locationService = [[ARLocatingService alloc] init];
	
	// if you want to show the camera view do this:
	
	UIImagePickerController *camera = [[UIImagePickerController alloc] init];
	camera.sourceType = UIImagePickerControllerSourceTypeCamera;
	camera.showsCameraControls = NO;
	camera.toolbarHidden = YES;
	camera.navigationBarHidden = YES;
	camera.wantsFullScreenLayout = YES;
	camera.cameraViewTransform = CGAffineTransformScale(camera.cameraViewTransform, 1.2, 1.3);
	

    // Add the view controller's view to the window and display.
    [self.window addSubview:viewController.view];
	[self.window insertSubview:camera.view atIndex:0];
    [self.window makeKeyAndVisible];
	
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	[device endGeneratingDeviceOrientationNotifications];
	[locationService stopLocating];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	
	// start in "normal" augmented reality view
	radarPosition = NO;
	
	// allow geolocations in a distance of x meter (default ist 1000)
	[ARGeoLocation updateMaxDistanceTo:20000000]; // 20000km
	
	
	// generate device orientation notifications for supporting the radar view
	[device beginGeneratingDeviceOrientationNotifications];
	[notificationCenter addObserver:self selector:@selector(deviceOrientationChanged:)
							   name:UIDeviceOrientationDidChangeNotification object:nil];
	
	
	// register for position notifications (optional)
	[[ARNotificationCenter sharedNotificationCenter] addObserverForLocationChanges:self selector:@selector(locationChanged:)];
	[[ARNotificationCenter sharedNotificationCenter] addObserverForCoreLocationError:self selector:@selector(locationErrorReceived:)];
	[[ARNotificationCenter sharedNotificationCenter] addObserverForHeadingChanges:self selector:@selector(headingChanged:)];
	
	// start the localization process
	[locationService startLocating];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
	[locationService release];
	
    [super dealloc];
}

#pragma mark notification handling

- (void)deviceOrientationChanged:(NSNotification *)notification {
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
	BOOL oldValue = radarPosition;
	
	switch (deviceOrientation) {
		case UIDeviceOrientationLandscapeLeft: 
			radarPosition = NO;
			break;
		case UIDeviceOrientationLandscapeRight:
			radarPosition = NO;
			break;
		case UIDeviceOrientationPortrait:
			radarPosition = NO;
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			radarPosition = NO;
			break;
		case UIDeviceOrientationFaceUp:
			radarPosition = YES;
			break;
		case UIDeviceOrientationFaceDown:
			radarPosition = NO;
			break;
	}
	
	// inform delegate about change
	if (oldValue != radarPosition) {
		[viewController.arControllerView activateRadarView:radarPosition];
	}
}


- (void) locationChanged:(NSNotification *) notification {
	// extract new location information from notification
	CLLocationDegrees latitude = [[[notification userInfo] objectForKey:@"latitude"] doubleValue];
	CLLocationDegrees longitude = [[[notification userInfo] objectForKey:@"longitude"] doubleValue];
	NSLog(@"location changed to lat: %f long: %f", latitude, longitude);
	
	// do something
}

- (void) headingChanged:(NSNotification *) notification {
	// extract new heading information from notificiation
	CLHeading *heading = [[notification userInfo] objectForKey:@"heading"];
	//NSLog(@"heading changed to %@", heading);
	
	// do something
}

- (void) locationErrorReceived:(NSNotification*) notification {
	// extract error information from notification
	NSError *error = [[notification userInfo] objectForKey:@"error"];
	NSLog(@"error: %s", error);
	
	// do something
}


@end
