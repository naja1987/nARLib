//
//  exampleARObject.m
//  example
//
//  Created by Naja von Schmude on 30.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ExampleARObject.h"


@implementation ExampleARObject

@synthesize name;

- (void) dealloc {
	[name release];
	
	[super dealloc];
}

@end
