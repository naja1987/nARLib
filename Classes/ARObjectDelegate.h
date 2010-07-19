//
//  ARObjectDelegate.h
//  nARLib
//
//  Created by Naja von Schmude on 15.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ARObjectDelegate

/**
 * Update's further data you implement in your ARObject. 
 * This method is called every time the location or the heading of the device is changed.
 */
- (void) update;

@end
