//
//  ARView.m
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import "ARView.h"


@implementation ARView

@synthesize delegate, backgroundLayer;

#pragma mark Constructors

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        delegate = nil;
		
		backgroundLayer = [[CALayer alloc] init];
		backgroundLayer.frame = self.bounds;		
		backgroundLayer.backgroundColor = [[UIColor clearColor] CGColor];
		backgroundLayer.opaque = NO;
		
		[self.layer addSublayer:backgroundLayer];
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
	delegate = nil;
    [super dealloc];
}

#pragma mark Implementation

- (BOOL) intersectsWithARView:(ARView *)otherView {
	if (otherView == nil) {
		return NO;
	}
	
	CGFloat x = self.frame.origin.x;
	CGFloat ovX = otherView.frame.origin.x;
	CGFloat y = self.frame.origin.y;
	CGFloat ovY = otherView.frame.origin.y;
	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;
	CGFloat ovWidth = otherView.frame.size.width;
	CGFloat ovHeight = otherView.frame.size.height;
	
	if(x + width < ovX || ovX + ovWidth < x) {
		return NO;
	}
	if (y + height < ovY || ovY + ovHeight < y) {
		return NO;
	}
	return YES;
}

- (BOOL) wouldIntersectWithARView:(ARView*) otherView atPosition:(CGPoint) position {
	if (otherView == nil) {
		return NO;
	}
	
	CGFloat x = position.x;
	CGFloat ovX = otherView.frame.origin.x;
	CGFloat y = position.y;
	CGFloat ovY = otherView.frame.origin.y;
	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;
	CGFloat ovWidth = otherView.frame.size.width;
	CGFloat ovHeight = otherView.frame.size.height;
	
	if(x + width < ovX || ovX + ovWidth < x) {
		return NO;
	}
	if (y + height < ovY || ovY + ovHeight < y) {
		return NO;
	}
	return YES;
}

- (CGFloat) distanceToOtherARView:(ARView*) view {
	return [self distanceBetweenPosition1:self.layer.position Position2:view.layer.position];
}

- (CGFloat) distanceBetweenPosition1:(CGPoint)p1 Position2:(CGPoint)p2 {
	CGFloat difX = p1.x - p2.x;
	CGFloat difY = p1.y - p2.y;
	return sqrt(difX * difX + difY * difY);
}

@end
