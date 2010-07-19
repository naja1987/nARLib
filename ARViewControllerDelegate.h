//
//  ARViewControllerDelegate.h
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCameraApartueAngle 50

// iPhone screen dimensions
#define kScreenWidth  320
#define kScreenHeight 480

@protocol ARViewControllerDelegate

- (void) updateDisplayWithHeading:(double) heading;
- (void) replaceViewsWithViewsFromObjectViewTriple:(NSMutableArray*) triples;

@end
