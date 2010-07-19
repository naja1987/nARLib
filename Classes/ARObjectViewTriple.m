//
//  ObjectViewTriple.m
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import "ARObjectViewTriple.h"


@implementation ARObjectViewTriple

@synthesize object, viewAR, viewRadar;

- (id) init {
	if (self = [super init]) {
		object = [[ARObject alloc] init];
		viewAR = [[ARView alloc] init];
		viewRadar = [[ARView alloc] init];
	}
	
	return self;
}

- (id)initWithObject:(ARObject *)obj ViewAR:(ARView*)vAR ViewRadar:(ARView*) vRadar {
	if (self = [super init]) {
		object = obj;
		viewAR = vAR;
		viewRadar = vRadar;
	}
	
	return self;
}

- (void) dealloc {
	[object release];
	[viewAR release];
	[viewRadar release];
	[super dealloc];
}

@end