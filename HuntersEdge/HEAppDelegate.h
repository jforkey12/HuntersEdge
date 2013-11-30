//
//  HEAppDelegate.h
//  Hunter's Edge
//
//  Created by James Forkey on 1/30/12.
//  Copyright (c) 2013 HF Development. All rights reserved.
//

static NSUInteger const kHEWallPostMaximumCharacterCount = 140;

static double const kHEFeetToMeters = 0.3048; // this is an exact value.
static double const kHEFeetToMiles = 5280.0; // this is an exact value.
static double const kHEWallPostMaximumSearchDistance = 100.0;
static double const kHEMetersInAKilometer = 1000.0; // this is an exact value.

static NSUInteger const kHEWallPostsSearch = 20; // query limit for pins and tableviewcells

// !!! SHOULD WE CHANGE THIS?  OTHERWISE LOCAL HUNTERS MAY NOT BE SHOWN.... !!!
static NSUInteger const kHEWallHuntersSearch = 25; // query limit for hunters to display

// Parse API key constants:
static NSString * const kHEParseHuntersClassKey = @"hunterLocations";
static NSString * const kHEParsePostsClassKey = @"Posts";
static NSString * const kHEParseUserKey = @"user";
static NSString * const kHEParseUsernameKey = @"username";
static NSString * const kHEParseTextKey = @"text";
static NSString * const kHEParseLocationKey = @"location";
static NSString * const kHEParseHunterLocationKey = @"userLocation";

// NSNotification userInfo keys:
static NSString * const kHEFilterDistanceKey = @"filterDistance";
static NSString * const kHELocationKey = @"location";

// Notification names:
static NSString * const kHEFilterDistanceChangeNotification = @"kHEFilterDistanceChangeNotification";
static NSString * const kHELocationChangeNotification = @"kHELocationChangeNotification";
static NSString * const kHEPostCreatedNotification = @"kHEPostCreatedNotification";

// UI strings:
static NSString * const kHEWallCantViewPost = @"Can’t view post! Get closer.";

#define HELocationAccuracy double

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class HEWelcomeViewController;

@interface HEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

@property (nonatomic, assign) CLLocationAccuracy filterDistance;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *pinDropLocation;

@property (nonatomic, strong) UITabBarController *tabBarController;

- (void)presentWelcomeViewController;

@end
