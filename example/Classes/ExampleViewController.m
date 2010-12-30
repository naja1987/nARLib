//
//  exampleViewController.m
//  example
//
//  Created by Naja von Schmude on 30.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ExampleViewController.h"

#import "ExampleARObject.h"
#import "ExampleARGeoLocation.h"
#import "ExampleARView.h"

@implementation ExampleViewController

@synthesize arControllerView;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// create the ar controller view and add it
	// this is the view where all the augmented reallity view get placed and updated
	arControllerView = [[ARControllerView alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenHeight, kScreenWidth)];
	[self.view insertSubview:arControllerView atIndex:0];
	
	// create some location based views
	ExampleARGeoLocation *berlin = [[ExampleARGeoLocation alloc] initWithLongitude:13.408056 Latitude:52.518611];
	berlin.name = @"Berlin";
	ExampleARGeoLocation *nyc = [[ExampleARGeoLocation alloc] initWithLongitude:-74.005833 Latitude:40.712778];
	nyc.name = @"New York";
	ExampleARGeoLocation *sydney = [[ExampleARGeoLocation alloc] initWithLongitude:151.2 Latitude:-33.85];
	sydney.name = @"Sydney";

	// create corresponding views (here the same view for ar view and radar view is used, you would prefert to have two seperate views ...)
	ExampleARView *berlinView = [[ExampleARView alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height / 2, 100, 30.0)];
	ExampleARView *nycView = [[ExampleARView alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height / 2, 100, 30.0)];
	ExampleARView *sydneyView = [[ExampleARView alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height / 2, 100, 30.0)];
	
	// add objects
	[arControllerView addObject:berlin WithViewAR:berlinView WithViewRadar:berlinView];
	[arControllerView addObject:nyc WithViewAR:nycView WithViewRadar:nycView];
	[arControllerView addObject:sydney WithViewAR:sydneyView WithViewRadar:sydneyView];
	
	
	// create some heading based views
	ExampleARObject *north = [[ExampleARObject alloc] initWithAngle:0.0];
	north.name = @"North";
	ExampleARObject *east = [[ExampleARObject alloc] initWithAngle:90.0];
	east.name = @"East";
	ExampleARObject *south = [[ExampleARObject alloc] initWithAngle:180.0];
	south.name = @"South";
	ExampleARObject *west = [[ExampleARObject alloc] initWithAngle:270.0];
	west.name = @"West";
	
	// create corresponding views (here the same view for ar view and radar view is used, you would prefert to have two seperate views ...)
	ExampleARView *northView = [[ExampleARView alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height / 2, 100, 30.0)];
	ExampleARView *eastView = [[ExampleARView alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height / 2, 100.0, 30.0)];
	ExampleARView *southView = [[ExampleARView alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height / 2, 100.0, 30.0)];
	ExampleARView *westView = [[ExampleARView alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height / 2, 100.0, 30.0)];
	
	
	// add objects. everything else is now done automaticly!
	[arControllerView addObject:north WithViewAR:northView WithViewRadar:northView];
	[arControllerView addObject:east WithViewAR:eastView WithViewRadar:eastView];
	[arControllerView addObject:south WithViewAR:southView WithViewRadar:southView];
	[arControllerView addObject:west WithViewAR:westView WithViewRadar:westView];

	
	// release everything
	[berlin release];
	[berlinView release];
	[nyc release];
	[nycView release];
	[sydney release];
	[sydneyView release];
	[north release];
	[northView release];
	[east release];
	[eastView release];
	[south release];
	[southView release];
	[west release];
	[westView release];
	
}




// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[arControllerView release];
	
    [super dealloc];
}

@end
