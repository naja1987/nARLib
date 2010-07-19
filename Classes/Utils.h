/*
 *  Utils.h
 *  nARLib
 *
 *  Created by Naja von Schmude on 17.07.10.
 *  Copyright 2010 Naja's Corner. All rights reserved.
 *
 */

// radians <-> degree conversion using CGFloat
CGFloat DegreesToRadians(CGFloat degrees) { 
	return degrees * M_PI / 180; 
};

CGFloat RadiansToDegrees(CGFloat radians) { 
	return radians * 180 / M_PI; 
};

