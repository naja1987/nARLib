//
//  exampleViewController.h
//  example
//
//  Created by Naja von Schmude on 30.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARControllerView.h"

@interface ExampleViewController : UIViewController {

	ARControllerView *arControllerView;
}

@property (nonatomic, retain) ARControllerView *arControllerView;

@end

