//
//  HEWallViewController.m
//  Hunter's Edge
//
//  Created by James Forkey on 1/30/12.
//  Copyright (c) 2013 HF Development. All rights reserved.
//

#import "HEWallViewController.h"

#import "JournalViewController.h"
#import "HEChatRoomViewController.h"
#import "HESettingsViewController.h"
#import "HEWallPostCreateViewController.h"
#import "HEAppDelegate.h"
#import "HEWallPostsTableViewController.h"
#import "HESearchRadius.h"
#import "HECircleView.h"
#import "HEPost.h"
#import <CoreLocation/CoreLocation.h>
#import "HunterEdgeDoc.h"

// private methods and properties
@interface HEWallViewController ()

@property (nonatomic, strong) CLLocationManager *_locationManager;
@property (nonatomic, strong) HESearchRadius *searchRadius;
@property (nonatomic, strong) HECircleView *circleView;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) HEWallPostsTableViewController *wallPostsTableViewController;
@property (nonatomic, assign) BOOL mapPinsPlaced;
@property (nonatomic, assign) BOOL mapPannedSinceLocationUpdate;

// posts:
@property (nonatomic, strong) NSMutableArray *allPosts;

- (void)startStandardUpdates;

// CLLocationManagerDelegate methods:
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

- (IBAction)settingsButtonSelected:(id)sender;
- (IBAction)postButtonSelected:(id)sender;
- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance;
- (void)updatePostsForLocation:(CLLocation *)location withNearbyDistance:(CLLocationAccuracy) filterDistance;

// NSNotification callbacks
- (void)distanceFilterDidChange:(NSNotification *)note;
- (void)locationDidChange:(NSNotification *)note;
- (void)postWasCreated:(NSNotification *)note;

@end

@implementation HEWallViewController

@synthesize mapView;
@synthesize _locationManager = locationManager;
@synthesize searchRadius;
@synthesize circleView;
@synthesize annotations;
@synthesize className;
@synthesize wallPostsTableViewController;
@synthesize allPosts;
@synthesize mapPinsPlaced;
@synthesize mapPannedSinceLocationUpdate;
@synthesize tabBar;
@synthesize journalItem, mapItem, groupChatItem, settingsItem;

@synthesize firstTab, secondTab, thirdTab, fourthTab, currentTab;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = @"Hunter's Edge";
		self.className = kHEParsePostsClassKey;
		annotations = [[NSMutableArray alloc] initWithCapacity:10];
		allPosts = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

	// Add the wall posts tableview as a subview with view containment (new in iOS 5.0):
	self.wallPostsTableViewController = [[HEWallPostsTableViewController alloc] initWithStyle:UITableViewStylePlain];
	[self addChildViewController:self.wallPostsTableViewController];

	self.wallPostsTableViewController.view.frame = CGRectMake(6.0f, 215.0f, 308.0f, self.view.bounds.size.height - 264.0f);
	[self.view addSubview:self.wallPostsTableViewController.view];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceFilterDidChange:) name:kHEFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kHELocationChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWasCreated:) name:kHEPostCreatedNotification object:nil];

	self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.332495f, -122.029095f), MKCoordinateSpanMake(0.008516f, 0.021801f));
	self.mapPannedSinceLocationUpdate = NO;
	[self startStandardUpdates];
	
	UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
										  initWithTarget:self action:@selector(handleLongPress:)];
	lpgr.minimumPressDuration = 1.0; //user needs to press for 1 second
	[self.mapView addGestureRecognizer:lpgr];

}

- (void)viewWillAppear:(BOOL)animated {
	[locationManager startUpdatingLocation];
	[super viewWillAppear:animated];
	[[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
	[locationManager stopUpdatingLocation];
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[locationManager stopUpdatingLocation];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kHEFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kHELocationChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kHEPostCreatedNotification object:nil];
	
	self.mapPinsPlaced = NO; // reset this for the next time we show the map.
}

#pragma mark - NSNotificationCenter notification handlers

- (void)distanceFilterDidChange:(NSNotification *)note {
	CLLocationAccuracy filterDistance = [[[note userInfo] objectForKey:kHEFilterDistanceKey] doubleValue];
	HEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	if (self.searchRadius == nil) {
		self.searchRadius = [[HESearchRadius alloc] initWithCoordinate:appDelegate.currentLocation.coordinate radius:appDelegate.filterDistance];
		[mapView addOverlay:self.searchRadius];
	} else {
		self.searchRadius.radius = appDelegate.filterDistance;
	}

	// Update our pins for the new filter distance:
	[self updatePostsForLocation:appDelegate.currentLocation withNearbyDistance:filterDistance];
	
	// If they panned the map since our last location update, don't recenter it.
	if (!self.mapPannedSinceLocationUpdate) {
		// Set the map's region centered on their location at 2x filterDistance
		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(appDelegate.currentLocation.coordinate, appDelegate.filterDistance * 2.0f, appDelegate.filterDistance * 2.0f);

		[mapView setRegion:newRegion animated:YES];
		self.mapPannedSinceLocationUpdate = NO;
	} else {
		// Just zoom to the new search radius (or maybe don't even do that?)
		MKCoordinateRegion currentRegion = mapView.region;
		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(currentRegion.center, appDelegate.filterDistance * 2.0f, appDelegate.filterDistance * 2.0f);

		BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
		[mapView setRegion:newRegion animated:YES];
		self.mapPannedSinceLocationUpdate = oldMapPannedValue;
	}
}

- (void)locationDidChange:(NSNotification *)note {
	HEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	// If they panned the map since our last location update, don't recenter it.
	if (!self.mapPannedSinceLocationUpdate) {
		// Set the map's region centered on their new location at 2x filterDistance
		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(appDelegate.currentLocation.coordinate, appDelegate.filterDistance * 2.0f, appDelegate.filterDistance * 2.0f);

		BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
		[mapView setRegion:newRegion animated:YES];
		self.mapPannedSinceLocationUpdate = oldMapPannedValue;
	} // else do nothing.

	// If we haven't drawn the search radius on the map, initialize it.
	if (self.searchRadius == nil) {
		self.searchRadius = [[HESearchRadius alloc] initWithCoordinate:appDelegate.currentLocation.coordinate radius:appDelegate.filterDistance];
		[mapView addOverlay:self.searchRadius];
	} else {
		self.searchRadius.coordinate = appDelegate.currentLocation.coordinate;
	}

	// Update the map with new pins:
	[self queryForAllPostsNearLocation:appDelegate.currentLocation withNearbyDistance:appDelegate.filterDistance];
	// And update the existing pins to reflect any changes in filter distance:
	[self updatePostsForLocation:appDelegate.currentLocation withNearbyDistance:appDelegate.filterDistance];
}

- (void)postWasCreated:(NSNotification *)note {
	HEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[self queryForAllPostsNearLocation:appDelegate.currentLocation withNearbyDistance:appDelegate.filterDistance];
}

#pragma mark - UITabBar-based actions

-(void)tabBar:(UITabBar *)localTabBar didSelectItem:(UITabBarItem *)item {
	NSLog(@"didSelectItem: %d", item.tag);
	int selectedTag = tabBar.selectedItem.tag;
	NSLog(@"%d", selectedTag);
	tabBar.tag = 0;
	
	if (selectedTag == 0) {
		HunterEdgeDoc *animal1 = [[HunterEdgeDoc alloc] initWithTitle:@"200lb Doe" rating:4 thumbImage:[UIImage imageNamed:@"doe.jpg"] fullImage:[UIImage imageNamed:@"doe.jpg"]];
		
		NSMutableArray *animals = [NSMutableArray arrayWithObjects:animal1, nil];
		
		UINavigationController * navController = (UINavigationController *) self.navigationController;
		
		JournalViewController *masterController = [[JournalViewController alloc] initWithNibName:@"JournalViewController" bundle:nil];
		
		masterController.animals = animals;
		
		for (UIView *subview in self.view.subviews) {
			if (subview != tabBar)
				[subview removeFromSuperview];
		}
		if (firstTab == nil)
			self.firstTab = masterController;
			//self.firstTab = [[JournalViewController alloc] initWithNibName:@"JournalViewController" bundle:nil];
		[self.view insertSubview:firstTab.view belowSubview:tabBar];
		if(currentTab != nil)
		{
			[currentTab.view removeFromSuperview];
		}
		currentTab = firstTab;
	}
	if (selectedTag == 1) {
		if(secondTab == nil)
			self.secondTab = [[HEWallViewController alloc] initWithNibName:@"HEWallViewController" bundle:nil];
		[self.view insertSubview:secondTab.view belowSubview:tabBar];
		if(currentTab != nil)
		{
			[currentTab.view removeFromSuperview];
		}
		currentTab = secondTab;
	}
	
	if (selectedTag == 2){
		for (UIView *subview in self.view.subviews) {
			if (subview != tabBar)
				[subview removeFromSuperview];
		}
		if(thirdTab == nil)
			self.thirdTab = [[HEChatRoomViewController alloc] initWithNibName:@"HEChatRoomViewController" bundle:nil];
		[self.view insertSubview:thirdTab.view belowSubview:tabBar];
		if(currentTab != nil)
		{
			[currentTab.view removeFromSuperview];
		}
		currentTab = thirdTab;
		[self.view insertSubview:thirdTab.view belowSubview:tabBar];
		
	}

	if (selectedTag == 3) {
		for (UIView *subview in self.view.subviews) {
			if (subview != tabBar) 
				[subview removeFromSuperview];
		}
		if(fourthTab == nil)
			self.fourthTab = [[HESettingsViewController alloc] initWithNibName:@"HESettingsViewController" bundle:nil];
		[self.view insertSubview:fourthTab.view belowSubview:tabBar];
		if(currentTab != nil)
		{
			[currentTab.view removeFromSuperview];
		}
		currentTab = fourthTab;
		[self.view insertSubview:currentTab.view belowSubview:tabBar];
		
	}
}

#pragma mark - UILongGestureRecognizer- based actions for UIMapView

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
	
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
	[self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
	
	MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
	
    annot.coordinate = touchMapCoordinate;
    
	//Moved actual pin add to post method
	//[self.mapView addAnnotation:annot];
	
	HEAppDelegate *appDelegate = (HEAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	CLLocation *tempLocation = [[CLLocation alloc] initWithLatitude:annot.coordinate.latitude longitude:annot.coordinate.longitude];

	NSLog(@"%f, %f", tempLocation.coordinate.latitude, tempLocation.coordinate.longitude);
	
	appDelegate.pinDropLocation = tempLocation;
	
	HEWallPostCreateViewController *createPostViewController = [[HEWallPostCreateViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController presentViewController:createPostViewController animated:YES completion:nil];

}

#pragma mark - CLLocationManagerDelegate methods and helpers

- (void)startStandardUpdates {
	if (nil == locationManager) {
		locationManager = [[CLLocationManager alloc] init];
	}

	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;

	// Set a movement threshold for new events.
	locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;

	[locationManager startUpdatingLocation];

	CLLocation *currentLocation = locationManager.location;
	if (currentLocation) {
		HEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		appDelegate.currentLocation = currentLocation;
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	switch (status) {
		case kCLAuthorizationStatusAuthorized:
			NSLog(@"kCLAuthorizationStatusAuthorized");
			// Re-enable the post button if it was disabled before.
			//self.navigationItem.rightBarButtonItem.enabled = YES;
			[locationManager startUpdatingLocation];
			break;
		case kCLAuthorizationStatusDenied:
			NSLog(@"kCLAuthorizationStatusDenied");
			{{
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hunter's Edge can’t access your current location.\n\nTo view nearby posts or create a post at your current location, turn on access for Hunter's Edge to your location in the Settings app under Location Services." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
				[alertView show];
				// Disable the post button.
				//self.navigationItem.rightBarButtonItem.enabled = NO;
			}}
			break;
		case kCLAuthorizationStatusNotDetermined:
			NSLog(@"kCLAuthorizationStatusNotDetermined");
			break;
		case kCLAuthorizationStatusRestricted:
			NSLog(@"kCLAuthorizationStatusRestricted");
			break;
	}
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
	NSLog(@"%s", __PRETTY_FUNCTION__);

	HEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.currentLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"Error: %@", [error description]);

	if (error.code == kCLErrorDenied) {
		[locationManager stopUpdatingLocation];
	} else if (error.code == kCLErrorLocationUnknown) {
		// todo: retry?
		// set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
		                                                message:[error description]
		                                               delegate:nil
		                                      cancelButtonTitle:nil
		                                      otherButtonTitles:@"Ok", nil];
		[alert show];
	}
}

#pragma mark - MKMapViewDelegate methods

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	MKOverlayView *result = nil;
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	
	// Only display the search radius in iOS 5.1+
	if (version >= 5.1f && [overlay isKindOfClass:[HESearchRadius class]]) {
		result = [[HECircleView alloc] initWithSearchRadius:(HESearchRadius *)overlay];
		[(MKOverlayPathView *)result setFillColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.2f]];
		[(MKOverlayPathView *)result setStrokeColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.7f]];
		[(MKOverlayPathView *)result setLineWidth:2.0];
	}
	return result;
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id<MKAnnotation>)annotation {
	// Let the system handle user location annotations.
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	}

	static NSString *pinIdentifier = @"CustomPinAnnotation";

	// Handle any custom annotations.
	if ([annotation isKindOfClass:[HEPost class]])
	{
		// Try to dequeue an existing pin view first.
		MKPinAnnotationView *pinView = (MKPinAnnotationView*)[aMapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];

		if (!pinView)
		{
			// If an existing pin view was not available, create one.
			pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
			                                          reuseIdentifier:pinIdentifier];
		}
		else {
			pinView.annotation = annotation;
		}
		pinView.pinColor = [(HEPost *)annotation pinColor];
		pinView.animatesDrop = [((HEPost *)annotation) animatesDrop];
		pinView.canShowCallout = YES;

		return pinView;
	}

	return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	id<MKAnnotation> annotation = [view annotation];
	if ([annotation isKindOfClass:[HEPost class]]) {
		HEPost *post = [view annotation];
		[wallPostsTableViewController highlightCellForPost:post];
	} else if ([annotation isKindOfClass:[MKUserLocation class]]) {
		// Center the map on the user's current location:
		HEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(appDelegate.currentLocation.coordinate, appDelegate.filterDistance * 2, appDelegate.filterDistance * 2);

		[self.mapView setRegion:newRegion animated:YES];
		self.mapPannedSinceLocationUpdate = NO;
	}
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	id<MKAnnotation> annotation = [view annotation];
	if ([annotation isKindOfClass:[HEPost class]]) {
		HEPost *post = [view annotation];
		[wallPostsTableViewController unhighlightCellForPost:post];
	}
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	self.mapPannedSinceLocationUpdate = YES;
}

#pragma mark - Fetch map pins

- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance {
	PFQuery *query = [PFQuery queryWithClassName:self.className];

	if (currentLocation == nil) {
		NSLog(@"%s got a nil location!", __PRETTY_FUNCTION__);
	}

	// If no objects are loaded in memory, we look to the cache first to fill the table
	// and then subsequently do a query against the network.
	if ([self.allPosts count] == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}

	// Query for posts sort of kind of near our current location.
	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
	[query whereKey:kHEParseLocationKey nearGeoPoint:point withinKilometers:kHEWallPostMaximumSearchDistance];
	[query includeKey:kHEParseUserKey];
	query.limit = kHEWallPostsSearch;

	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (error) {
			NSLog(@"error in geo query!"); // todo why is this ever happening?
		} else {
			// We need to make new post objects from objects,
			// and update allPosts and the map to reflect this new array.
			// But we don't want to remove all annotations from the mapview blindly,
			// so let's do some work to figure out what's new and what needs removing.

			// 1. Find genuinely new posts:
			NSMutableArray *newPosts = [[NSMutableArray alloc] initWithCapacity:kHEWallPostsSearch];
			// (Cache the objects we make for the search in step 2:)
			NSMutableArray *allNewPosts = [[NSMutableArray alloc] initWithCapacity:kHEWallPostsSearch];
			for (PFObject *object in objects) {
				HEPost *newPost = [[HEPost alloc] initWithPFObject:object];
				[allNewPosts addObject:newPost];
				BOOL found = NO;
				for (HEPost *currentPost in allPosts) {
					if ([newPost equalToPost:currentPost]) {
						found = YES;
					}
				}
				if (!found) {
					[newPosts addObject:newPost];
				}
			}
			// newPosts now contains our new objects.

			// 2. Find posts in allPosts that didn't make the cut.
			NSMutableArray *postsToRemove = [[NSMutableArray alloc] initWithCapacity:kHEWallPostsSearch];
			for (HEPost *currentPost in allPosts) {
				BOOL found = NO;
				// Use our object cache from the first loop to save some work.
				for (HEPost *allNewPost in allNewPosts) {
					if ([currentPost equalToPost:allNewPost]) {
						found = YES;
					}
				}
				if (!found) {
					[postsToRemove addObject:currentPost];
				}
			}
			// postsToRemove has objects that didn't come in with our new results.

			// 3. Configure our new posts; these are about to go onto the map.
			for (HEPost *newPost in newPosts) {
				CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:newPost.coordinate.latitude longitude:newPost.coordinate.longitude];
				// if this post is outside the filter distance, don't show the regular callout.
				CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
				[newPost setTitleAndSubtitleOutsideDistance:( distanceFromCurrent > nearbyDistance ? YES : NO )];
				// Animate all pins after the initial load:
				newPost.animatesDrop = mapPinsPlaced;
			}

			// At this point, newAllPosts contains a new list of post objects.
			// We should add everything in newPosts to the map, remove everything in postsToRemove,
			// and add newPosts to allPosts.
			[mapView removeAnnotations:postsToRemove];
			[mapView addAnnotations:newPosts];
			[allPosts addObjectsFromArray:newPosts];
			[allPosts removeObjectsInArray:postsToRemove];

			self.mapPinsPlaced = YES;
		}
	}];
}

// When we update the search filter distance, we need to update our pins' titles to match.
- (void)updatePostsForLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy) nearbyDistance {
	for (HEPost *post in allPosts) {
		CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:post.coordinate.latitude longitude:post.coordinate.longitude];
		// if this post is outside the filter distance, don't show the regular callout.
		CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
		if (distanceFromCurrent > nearbyDistance) { // Outside search radius
			[post setTitleAndSubtitleOutsideDistance:YES];
			[mapView viewForAnnotation:post];
			[(MKPinAnnotationView *) [mapView viewForAnnotation:post] setPinColor:post.pinColor];
		} else {
			[post setTitleAndSubtitleOutsideDistance:NO]; // Inside search radius
			[mapView viewForAnnotation:post];
			[(MKPinAnnotationView *) [mapView viewForAnnotation:post] setPinColor:post.pinColor];
		}
	}
}

@end
