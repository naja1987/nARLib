//
//  ARControllerViewRadar.h
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARControllerViewDelegate.h"

@interface ARControllerViewRadar : UIView <ARControllerViewDelegate> {
	
	NSMutableArray	*arTriples;
	double			currentHeading;
	
	UIImage			*radarImage;
	UIImageView		*imageView;
}

@property (assign) double currentHeading;

@end
