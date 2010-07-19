//
//  ARNotificationCenter.m
//  nARLib
//
//  Created by Naja von Schmude on 14.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import "ARNotificationCenter.h"


@implementation ARNotificationCenter

#pragma mark Constructors

static ARNotificationCenter *sharedNotificationCenter = nil;

- (id) init {
	if (self = [super init]) {
		notificationCenter = [NSNotificationCenter defaultCenter];
	}
	
	return self;
}

+ (ARNotificationCenter*) sharedNotificationCenter
{
    if (sharedNotificationCenter == nil) {
        sharedNotificationCenter = [[super allocWithZone:NULL] init];
    }
    return sharedNotificationCenter;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedNotificationCenter];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

#pragma mark Register/ Unregister

- (void) addObserverForHeadingChanges:(NSObject *)observer selector:(SEL)notificationSelector {
	[notificationCenter addObserver:observer selector:notificationSelector name:kHeadingChangeNotification object:nil];
}

- (void) addObserverForLocationChanges:(NSObject *)observer selector:(SEL)notificationSelector {
	[notificationCenter addObserver:observer selector:notificationSelector name:kLocationChangeNotification object:nil];
}

- (void) removeObserver:(NSObject *)observer {
	[notificationCenter removeObserver:observer];
}

@end
