//
//  ARControllerViewAugmentedReality.h
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARControllerViewDelegate.h"
#import "ARObjectViewTriple.h"

@interface ARControllerViewAugmentedReality : UIView <ARControllerViewDelegate> {
	NSMutableArray	*arTriples;
	UIView			*transformerView;
	
	double			currentHeading;
}

@property (assign) double currentHeading;

@end
