//
//  HEWallViewController.h
//  Hunter's Edge
//
//  Created by James Forkey on 1/30/12.
//  Copyright (c) 2013 HF Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "HEPost.h"
#import "HESettingsViewController.h"

@interface HEWallViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UITabBarDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UITabBar *tabBar;
@property (nonatomic, strong) IBOutlet UITabBarItem *journalItem;
@property (nonatomic, strong) IBOutlet UITabBarItem *mapItem;
@property (nonatomic, strong) IBOutlet UITabBarItem *groupChatItem;
@property (nonatomic, strong) IBOutlet UITabBarItem *settingsItem;

@property (nonatomic, retain) UIViewController *thirdTab;
@property (nonatomic, retain) UIViewController *secondTab;
@property (nonatomic, retain) UIViewController *firstTab;
@property (nonatomic, retain) HESettingsViewController *fourthTab;
@property (nonatomic, assign) UIViewController *currentTab;
@property (nonatomic, retain) UILongPressGestureRecognizer *lpgr;

@end

@protocol HEWallViewControllerHighlight <NSObject>

- (void)highlightCellForPost:(HEPost *)post;
- (void)unhighlightCellForPost:(HEPost *)post;

@end
