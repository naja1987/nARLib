//
//  exampleARView.m
//  example
//
//  Created by Naja von Schmude on 30.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ExampleARView.h"

#import "ExampleARObject.h"
#import "ExampleARGeoLocation.h"

@implementation ExampleARView

@synthesize nameLabel;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
		nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x+2, self.bounds.origin.y + 2, self.bounds.size.width - 4, self.bounds.size.height -4)];
		nameLabel.opaque = NO;
		nameLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		nameLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1];
		
		backgroundLayer.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.65] CGColor];
		backgroundLayer.opacity = 1;
		backgroundLayer.cornerRadius = 5;
		
		self.opaque = NO;
		
		[self addSubview:nameLabel];
		
		delegate = self;
		
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	[nameLabel release];
	
    [super dealloc];
}

#pragma mark delegate implementation

// insert here specific update information for the view
- (void) updateWithInfosFromObject:(ARObject *)object {
	
	
	if ([object isMemberOfClass:[ExampleARObject class]]) {
		nameLabel.text = ((ExampleARObject *) object).name;
	}
	else if ([object isMemberOfClass:[ExampleARGeoLocation class]]) {
		nameLabel.text = ((ExampleARGeoLocation *) object).name;
	}
	
	
}

@end
