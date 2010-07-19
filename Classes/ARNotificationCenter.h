//
//  ARNotificationCenter.h
//  nARLib
//
//  Created by Naja von Schmude on 14.07.10.
//  Copyright 2010 Naja's Corner. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHeadingChangeNotification @"ARHeadingChangeNotification"
#define kLocationChangeNotification @"ARLocationChangeNotification"
#define kCoreLocationErrorNotification @"ARCoreLocationErrorNotification"


@interface ARNotificationCenter : NSObject {
	NSNotificationCenter *notificationCenter;
}

+ (ARNotificationCenter*) sharedNotificationCenter;

- (void) addObserverForLocationChanges:(NSObject*) observer selector:(SEL) notificationSelector;
- (void) addObserverForHeadingChanges:(NSObject*) observer selector:(SEL) notificationSelector;
- (void) addObserverForCoreLocationError:(NSObject*) observer selector:(SEL) notificationSelector;

- (void) removeObserver:(NSObject*) observer;

@end
