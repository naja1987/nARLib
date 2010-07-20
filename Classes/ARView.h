//
//  ARView.h
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ARViewDelegate.h"

@interface ARView : UIView {

	id<ARViewDelegate>	delegate;
	CALayer				*backgroundLayer;
	UIColor				*defaultBackgroundColor;
}

@property (nonatomic, assign)	id<ARViewDelegate>	delegate;
@property (nonatomic, readonly)	CALayer				*backgroundLayer;
@property (nonatomic, retain)	UIColor				*defaultBackgroundColor;

/**
 * Tests, if self intersects with otherView
 * @param otherView
 * @return
 */
- (BOOL) intersectsWithARView:(ARView*) otherView;

- (BOOL) wouldIntersectWithARView:(ARView *)otherView atPosition:(CGPoint)position;

- (CGFloat) distanceToOtherARView:(ARView *)view;

- (CGFloat) distanceBetweenPosition1:(CGPoint)p1 Position2:(CGPoint)p2;
@end
