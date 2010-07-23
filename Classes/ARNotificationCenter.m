/*
 Copyright (c) 2010, Naja von Schmude
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the organization nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

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

- (void) addObserverForCoreLocationError:(NSObject *)observer selector:(SEL)notificationSelector {
	[notificationCenter addObserver:observer selector:notificationSelector name:kCoreLocationErrorNotification object:nil];
}

- (void) removeObserver:(NSObject *)observer {
	[notificationCenter removeObserver:observer];
}

@end
