//
//  ARViewDelegate.h
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARObject.h"

@protocol ARViewDelegate

- (void) updateWithInfosFromObject:(ARObject*) object;

@end
