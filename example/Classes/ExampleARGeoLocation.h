//
//  exampleARGeoLocation.h
//  example
//
//  Created by Naja von Schmude on 30.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ARGeoLocation.h"

// Geo location based object

@interface ExampleARGeoLocation : ARGeoLocation {

	NSString *name;
}

@property (nonatomic, retain) NSString *name;

@end
