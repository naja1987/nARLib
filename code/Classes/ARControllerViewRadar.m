/*
 Copyright (c) 2010, Naja von Schmude
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the organization nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

//
//  ARControllerViewRadar.m
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import "ARControllerViewRadar.h"
#import "ARView.h"
#import "Utils.h"
#import "ARGeoLocation.h"
#import "ARObjectViewTriple.h"

@interface ARControllerViewRadar (Private)

- (CGPoint) calculatePositionOfARObjectViewTriple:(ARObjectViewTriple*) triple;
- (void) moveAndTransformARViewOfTriple:(ARObjectViewTriple*) triple;

@end


@implementation ARControllerViewRadar

@synthesize currentHeading;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		arTriples = [[NSMutableArray alloc] init];
		
		radarImage = [UIImage imageNamed:@"radar_circle.png"];
		imageView = [[UIImageView alloc] initWithImage:radarImage];
		imageView.frame = self.frame;
		
		self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		self.opaque = NO;
		self.autoresizesSubviews = YES;
		
		imageView.contentMode = UIViewContentModeCenter;
		imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
		
		[self addSubview:imageView];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


- (void)dealloc {
	for (ARObjectViewTriple *triple in arTriples) {
		[triple.viewRadar removeFromSuperview];
	}
	
	[arTriples removeAllObjects];
	[arTriples release];
	
	[imageView removeFromSuperview];
	[imageView release];
	
    [super dealloc];
}

#pragma mark Delegate Implementation

- (void) updateDisplayWithHeading:(double) heading {
	@synchronized(self) {
		
		currentHeading = heading;
		for (ARObjectViewTriple *triple in arTriples) {
			[self moveAndTransformARViewOfTriple:triple];
		}
		
	}
}

- (void) replaceViewsWithViewsFromObjectViewTriple:(NSMutableArray*) triples {
	@synchronized(self) {
		
		for (ARObjectViewTriple *triple in arTriples) {
			[triple.viewRadar removeFromSuperview];
		}
		[arTriples removeAllObjects];
		
		for (ARObjectViewTriple *triple in triples) {
			
			CGPoint p = [self calculatePositionOfARObjectViewTriple:triple];
			triple.viewRadar.layer.position = p;
			
			[arTriples addObject:triple];
			[self addSubview:triple.viewRadar];
			
			[self moveAndTransformARViewOfTriple:triple];
		}
		
	}
}

- (void) redraw {
	@synchronized(self) {
		
		for (ARObjectViewTriple *triple in arTriples) {
			[self moveAndTransformARViewOfTriple:triple];
		}
		
	}
}

- (void) moveAndTransformARViewOfTriple:(ARObjectViewTriple *)triple {
	CGPoint p = CGPointMake(-1, -1);
	
	CGFloat centerX = kScreenHeight / 2; // 160
	CGFloat centerY = kScreenWidth / 2; // 240
	CGPoint centerPosition = CGPointMake(centerX, centerY);
	
	CGFloat vectorLength = [triple.viewRadar distanceBetweenPosition1:triple.viewRadar.layer.position Position2:centerPosition];
	
	// mark white when in view in the 360° view
	if (fabsf(triple.object.absoluteAngle - currentHeading) < 25) {
		triple.viewRadar.backgroundLayer.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.65].CGColor;
	}
	else {
		if (triple.viewRadar.defaultBackgroundColor != nil) {
			triple.viewRadar.backgroundLayer.backgroundColor = triple.viewRadar.defaultBackgroundColor.CGColor;
		}
		else {
			triple.viewRadar.backgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
		}
	}
	
	// calculate x and y position
	CGFloat posX = 0;
	CGFloat posY = 0;
	CGFloat angle = DegreesToRadians(fmodf(triple.object.absoluteAngle - currentHeading + 360.0, 360.0));
	double cos_ = cos(angle);
	double sin_ = sin(angle);
	
	// interchange sin and cos because on the x-axis are 0°. then, the angle counts clockwise
	posX = centerX + sin_ * vectorLength;
	posY = centerY - cos_ * vectorLength;
	
	p.x = posX;
	p.y = posY;
	
	// calculate last spotView with intersection
	ARObjectViewTriple *lastTripleWithIntersection = nil;
	CGFloat distance = -1;
	
	CGPoint origin = p;
	origin.x -= triple.viewRadar.frame.size.width / 2;
	origin.y -= triple.viewRadar.frame.size.height / 2;
	
	for (ARObjectViewTriple *t in arTriples) {
		if (t == triple) {
			// every spot after this in spotViews wasn't moved yet, so we can't test for intersection
			break;
		}
		
		if ([triple.viewRadar wouldIntersectWithARView:t.viewRadar atPosition:origin]) {
			CGFloat dist = [t.viewRadar distanceBetweenPosition1:t.viewRadar.layer.position Position2:centerPosition];
			//	NSLog(@"Intersection between %@ und %@ (dist: %f, pos: (%f, %f)", spotView, sv, dist, p.x, p.y);
			if (dist > distance) {
				distance = dist;
				lastTripleWithIntersection = t;
			}
		}
	}
	
	// if there is a intersection, then move the spot in it's heading direction until there is no intersection
	if (lastTripleWithIntersection != nil) {
		
		CGFloat offsetX = 0;
		CGFloat offsetY = 0;
		CGFloat width = triple.viewRadar.frame.size.width;
		CGFloat height = triple.viewRadar.frame.size.height;
		
		int i = 2;
		
		while ([triple.viewRadar wouldIntersectWithARView:lastTripleWithIntersection.viewRadar atPosition:CGPointMake(posX + offsetX - width /2, posY - offsetY - height / 2)]) {
			offsetX = sin_ * i;
			offsetY = cos_ * i;
			i += 1;
		}
		
		p.x = posX + offsetX;
		p.y = posY - offsetY; 
		
	}
	
	triple.viewRadar.layer.position = p;
	
	[UIView beginAnimations:@"RadarViewMove" context:NULL];
	[UIView setAnimationDuration:0.25];
	
	if (p.x < triple.viewRadar.frame.size.width / 2 || p.x > 480 - triple.viewRadar.frame.size.width / 2) {
		triple.viewRadar.alpha = 0.0;
	}
	else if (p.y < triple.viewRadar.frame.size.height / 2 || p.y > 320 - triple.viewRadar.frame.size.height / 2) {
		triple.viewRadar.alpha = 0.0;
	}
	// hide spots when outside the current range
	else if ([triple.object isKindOfClass:[ARGeoLocation class]] && ((ARGeoLocation*) triple.object).distanceFromCurrentLocation > [ARGeoLocation maxDistance]) {
		triple.viewRadar.alpha = 0.0;
	}
	else {
		triple.viewRadar.alpha = 1.0;
	}
	
	[UIView commitAnimations];
}

- (CGPoint) calculatePositionOfARObjectViewTriple:(ARObjectViewTriple*) triple {
	CGFloat centerX = kScreenHeight / 2; // 160
	CGFloat centerY = kScreenWidth / 2; // 240
	
	CGFloat vectorLength;
	// move to corresponding distance on the radar when it's a geolocation
	if ([triple.object isKindOfClass:[ARGeoLocation class]]) {
		vectorLength = ((ARGeoLocation*) triple.object).distanceFromCurrentLocation / [ARGeoLocation maxDistance] * centerY;
	}
	else {
		vectorLength = centerY / 3;
	}
	
	// calculate x and y position
	CGFloat posX = 0;
	CGFloat posY = 0;
	CGFloat angle = DegreesToRadians(fmodf(triple.object.absoluteAngle - currentHeading + 360.0, 360.0));
	double cos_ = cos(angle);
	double sin_ = sin(angle);
	
	// interchange sin and cos because on the x-axis are 0°. then, the angle counte clockwise
	posX = centerX + sin_ * vectorLength;
	posY = centerY - cos_ * vectorLength;
	
	return CGPointMake(posX, posY);
	
}


@end
