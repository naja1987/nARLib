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
//  ARView.m
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import "ARView.h"


@implementation ARView

@synthesize delegate, backgroundLayer, defaultBackgroundColor;

#pragma mark Constructors

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        delegate = nil;
		
		backgroundLayer = [[CALayer alloc] init];
		backgroundLayer.frame = self.bounds;		
		backgroundLayer.backgroundColor = [[UIColor clearColor] CGColor];
		backgroundLayer.opaque = NO;
		
		defaultBackgroundColor = nil;
		
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

	[defaultBackgroundColor release];
	[backgroundLayer release];
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

- (CGFloat) distanceToOtherARView:(ARView*) otherView {
	return [self distanceBetweenPosition1:self.layer.position Position2:otherView.layer.position];
}

- (CGFloat) distanceBetweenPosition1:(CGPoint)p1 Position2:(CGPoint)p2 {
	CGFloat difX = p1.x - p2.x;
	CGFloat difY = p1.y - p2.y;
	return sqrt(difX * difX + difY * difY);
}

@end
