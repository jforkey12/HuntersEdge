//
//  HESearchRadius.m
//  Hunter's Edge
//
//  Created by James Forkey on 2/8/12.
//  Copyright (c) 2013 HF Development. All rights reserved.
//

#import "HESearchRadius.h"

@implementation HESearchRadius

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate radius:(CLLocationDistance)aRadius {
	self = [super init];
	if (self) {
		self.coordinate = aCoordinate;
		self.radius = aRadius;
	}
	return self;
}

- (MKMapRect)boundingMapRect {
	return MKMapRectWorld;
}

@end
