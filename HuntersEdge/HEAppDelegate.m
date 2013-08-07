//
//  HEAppDelegate.m
//  Hunter's Edge
//
//  Created by James Forkey on 1/30/12.
//  Copyright (c) 2013 HF Development. All rights reserved.
//

static NSString * const defaultsFilterDistanceKey = @"filterDistance";
static NSString * const defaultsLocationKey = @"currentLocation";

#import "HEAppDelegate.h"

#import <Parse/Parse.h>

#import "HEWelcomeViewController.h"
#import "HEWallViewController.h"

@interface HEAppDelegate ()


@end

@implementation HEAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize filterDistance;
@synthesize currentLocation;
@synthesize tabBarController;
@synthesize pinDropLocation;

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	[Parse setApplicationId:@"R17iFzDeT9M0vddj7pVsS1JSJMZquqO6TNzq01nB" clientKey:@"bm2XdDAcRqyoy9OKmnEQSzl1VCFtuwCuGAofEye8"];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	
/*	self.tabBarController = [[UITabBarController alloc] init];
	
	HEWallViewController *HeVC = [[HEWallViewController alloc] initWithNibName:@"HEWallViewController" bundle:nil];
	
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:HEWallViewController, nil];
*/	
	// Grab values from NSUserDefaults:
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	// Set the global tint on the navigation bar
/*	[[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:200.0f/255.0f green:83.0f/255.0f blue:70.0f/255.0f alpha:1.0f]];
	[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bar.png"] forBarMetrics:UIBarMetricsDefault];
*/
	// Desired search radius:
	if ([userDefaults doubleForKey:defaultsFilterDistanceKey]) {
		// use the ivar instead of self.accuracy to avoid an unnecessary write to NAND on launch.
		filterDistance = [userDefaults doubleForKey:defaultsFilterDistanceKey];
	} else {
		// if we have no accuracy in defaults, set it to 1000 feet.
		self.filterDistance = 1000 * kHEFeetToMeters;
	}

	UINavigationController *navController = nil;

	if ([PFUser currentUser]) {
		// Skip straight to the main view.
		HEWallViewController *wallViewController = [[HEWallViewController alloc] initWithNibName:nil bundle:nil];
		navController = [[UINavigationController alloc] initWithRootViewController:wallViewController];
		navController.navigationBarHidden = YES;
		self.viewController = navController;
		self.window.rootViewController = self.viewController;
	} else {
		// Go to the welcome screen and have them log in or create an account.
		[self presentWelcomeViewController];
	}
	
	[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
	
    [self.window makeKeyAndVisible];
    return YES;
}


#pragma mark - HEAppDelegate

- (void)setFilterDistance:(CLLocationAccuracy)aFilterDistance {
	filterDistance = aFilterDistance;

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setDouble:filterDistance forKey:defaultsFilterDistanceKey];
	[userDefaults synchronize];

	// Notify the app of the filterDistance change:
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:filterDistance] forKey:kHEFilterDistanceKey];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kHEFilterDistanceChangeNotification object:nil userInfo:userInfo];
	});
}

- (void)setPinDropLocation:(CLLocation *)aPinLocation {
	pinDropLocation = aPinLocation;
	
}

- (void)setCurrentLocation:(CLLocation *)aCurrentLocation {
	currentLocation = aCurrentLocation;

	// Notify the app of the location change:
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:currentLocation forKey:kHELocationKey];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kHELocationChangeNotification object:nil userInfo:userInfo];
	});
}

- (void)presentWelcomeViewController {
	// Go to the welcome screen and have them log in or create an account.
	HEWelcomeViewController *welcomeViewController = [[HEWelcomeViewController alloc] initWithNibName:@"HEWelcomeViewController" bundle:nil];
	welcomeViewController.title = @"Welcome to Hunter's Edge";
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
	navController.navigationBarHidden = YES;

	self.viewController = navController;
	self.window.rootViewController = self.viewController;
}

@end
