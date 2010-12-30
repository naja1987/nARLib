//
//  exampleARView.h
//  example
//
//  Created by Naja von Schmude on 30.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARView.h"
#import "ARViewDelegate.h"

@interface ExampleARView : ARView <ARViewDelegate> {
	UILabel *nameLabel;
}

@property (nonatomic, retain) UILabel *nameLabel;

@end
