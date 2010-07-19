//
//  ARRadarViewController.h
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARViewControllerDelegate.h"

@interface ARRadarViewController : UIViewController <ARViewControllerDelegate> {
	
	NSMutableArray	*arTriples;
	double			currentHeading;
}

@end
