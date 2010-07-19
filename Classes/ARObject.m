//
//  ARObject.m
//  nARLib
//
//  Created by Naja von Schmude on 13.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import "ARObject.h"


@implementation ARObject

@synthesize	delegate,
			absoluteAngle,
			angleToCurrentHeading;


#pragma mark Constructors


- (id) init {
	if (self = [super init]) {
		absoluteAngle = -1;
		angleToCurrentHeading = -1;
		delegate = nil;
	}
	
	return self;
}

- (id) initWithAngle:(double)angle {
	if (self = [super init]) {
		absoluteAngle = angle;
		angleToCurrentHeading = -1;
		delegate = nil;
	}
	
	return self;
}

- (void) dealloc {
	delegate = nil;
	[super dealloc];
}

#pragma mark Implementation

- (void) updateWithNewHeading:(double)heading {
	double tmpAngle = heading - absoluteAngle;
	while(tmpAngle < 0.0) {
		tmpAngle += 360.0;
	}
	while (tmpAngle > 360.0) {
		tmpAngle -= 360.0;
	}
	
	angleToCurrentHeading = tmpAngle;
}

- (NSUInteger) hash {
	int prime = 31;
	int result = 1;

	result = prime * result + absoluteAngle;
	return result;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToARObject:other];
}

- (BOOL)isEqualToARObject:(ARObject*)other {
    if (self == other)
        return YES;
	if (absoluteAngle == other.absoluteAngle) {
		return YES;
	}
	return NO;
}

- (NSString*) description {
	return [NSString stringWithFormat:@"absAngle %f angleToCurrentHeading: %f", absoluteAngle, angleToCurrentHeading];
}


@end
