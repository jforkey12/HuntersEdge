//
//  HEPost.m
//  Hunter's Edge
//
//  Created by James Forkey on 2/8/12.
//  Copyright (c) 2013 HF Development. All rights reserved.
//

#import "HEHunter.h"
#import "HEAppDelegate.h"

@interface HEHunter ()

// Redefine these properties to make them read/write for internal class accesses and mutations.
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFGeoPoint *geopoint;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign) MKPinAnnotationColor pinColor;

@end

@implementation HEHunter

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle andSubtitle:(NSString *)aSubtitle {
	self = [super init];
	if (self) {
		self.coordinate = aCoordinate;
		self.title = aTitle;
		self.subtitle = aSubtitle;
		self.animatesDrop = NO;
	}
	return self;
}

- (id)initWithPFObject:(PFObject *)anObject {
	self.object = anObject;
	self.geopoint = [anObject objectForKey:kHEParseLocationKey];
	self.user = [anObject objectForKey:kHEParseUserKey];

	[anObject fetchIfNeeded]; 
	CLLocationCoordinate2D aCoordinate = CLLocationCoordinate2DMake(self.geopoint.latitude, self.geopoint.longitude);
	NSString *aTitle = [anObject objectForKey:kHEParseTextKey];
	NSString *aSubtitle = [[anObject objectForKey:kHEParseUserKey] objectForKey:kHEParseUsernameKey];

	return [self initWithCoordinate:aCoordinate andTitle:aTitle andSubtitle:aSubtitle];
}

- (BOOL)equalToHunter:(HEHunter *)aHunter {
	if (aHunter == nil) {
		return NO;
	}

	if (aHunter.object && self.object) {
		// We have a PFObject inside the HEHunter, use that instead.
		if ([aHunter.object.objectId compare:self.object.objectId] != NSOrderedSame) {
			return NO;
		}
		return YES;
	} else {
		// Fallback code:

		if ([aHunter.title compare:self.title] != NSOrderedSame ||
			[aHunter.subtitle compare:self.subtitle] != NSOrderedSame ||
			aHunter.coordinate.latitude != self.coordinate.latitude ||
			aHunter.coordinate.longitude != self.coordinate.longitude ) {
			return NO;
		}

		return YES;
	}
}

- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside {
	if (outside) {
		self.subtitle = nil;
		self.title = kHEWallCantViewPost;
		self.pinColor = MKPinAnnotationColorPurple;
	} else {
		self.title = [self.object objectForKey:kHEParseTextKey];
		self.subtitle = [[self.object objectForKey:kHEParseUserKey] objectForKey:kHEParseUsernameKey];
		self.pinColor = MKPinAnnotationColorPurple;
	}
}

@end
