//
//  ObjectViewTriple.h
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ARObject.h"
#import "ARView.h"

@interface ARObjectViewTriple : NSObject {
	ARObject *object;
	ARView *viewAR;
	ARView *viewRadar;
}

@property (nonatomic, retain) ARObject	*object;
@property (nonatomic, retain) ARView	*viewAR;
@property (nonatomic, retain) ARView	*viewRadar;

- (id) initWithObject:(ARObject*) obj ViewAR:(ARView*) vAR ViewRadar:(ARView*) vRadar;

@end
