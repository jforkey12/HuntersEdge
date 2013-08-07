//
//  HESettingsViewController.m
//  Hunter's Edge
//
//  Created by James Forkey on 1/30/12.
//  Copyright (c) 2013 HF Development. All rights reserved.
//

#import "HESettingsViewController.h"
#import "HEWallViewController.h"

#import "HEAppDelegate.h"
#import <Parse/Parse.h>

@interface HESettingsViewController ()

- (NSString *)distanceLabelForCell:(NSIndexPath *)indexPath;
- (HELocationAccuracy)distanceForCell:(NSIndexPath *)indexPath;

@property (nonatomic, assign) CLLocationAccuracy filterDistance;

@end

// UITableView enum-based configuration via Fraser Speirs: http://speirs.org/blog/2008/10/11/a-technique-for-using-uitableview-and-retaining-your-sanity.html
typedef enum {
	kHESettingsTableViewDistance = 0,
	kHESettingsTableViewLogout,
	kHESettingsTableViewNumberOfSections
} kHESettingsTableViewSections;

typedef enum {
	kHESettingsLogoutDialogLogout = 0,
	kHESettingsLogoutDialogCancel,
	kHESettingsLogoutDialogNumberOfButtons
} kHESettingsLogoutDialogButtons;

typedef enum {
	kHESettingsTableViewDistanceSection250FeetRow = 0,
	kHESettingsTableViewDistanceSection1000FeetRow,
	kHESettingsTableViewDistanceSection1MileRow,
	kHESettingsTableViewDistanceNumberOfRows
} kHESettingsTableViewDistanceSectionRows;

static uint16_t const kHESettingsTableViewLogoutNumberOfRows = 1;

@implementation HESettingsViewController

@synthesize tableView;
@synthesize filterDistance;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		HEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		self.filterDistance = appDelegate.filterDistance;
    }
    return self;
}


#pragma mark - Custom setters

// Always fault our filter distance through to the app delegate. We just cache it locally because it's used in the tableview's cells.
- (void)setFilterDistance:(CLLocationAccuracy)aFilterDistance {
	HEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.filterDistance = aFilterDistance;
	filterDistance = aFilterDistance;
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private helper methods

- (NSString *)distanceLabelForCell:(NSIndexPath *)indexPath {
	NSString *cellText = nil;
	switch (indexPath.row) {
		case kHESettingsTableViewDistanceSection250FeetRow:
			cellText = @"250 feet";
			break;
		case kHESettingsTableViewDistanceSection1000FeetRow:
			cellText = @"1000 feet";
			break;
		case kHESettingsTableViewDistanceSection1MileRow:
			cellText = @"1 Mile";
			break;
		case kHESettingsTableViewDistanceNumberOfRows: // never reached.
		default:
			cellText = @"The universe";
			break;
	}
	return cellText;
}

- (HELocationAccuracy)distanceForCell:(NSIndexPath *)indexPath {
	HELocationAccuracy distance = 0.0;
	switch (indexPath.row) {
		case kHESettingsTableViewDistanceSection250FeetRow:
			distance = 250;
			break;
		case kHESettingsTableViewDistanceSection1000FeetRow:
			distance = 1000;
			break;
		case kHESettingsTableViewDistanceSection1MileRow:
			distance = 528000;
			break;
		case kHESettingsTableViewDistanceNumberOfRows: // never reached.
		default:
			distance = 10000 * kHEFeetToMiles;
			break;
	}
	
	return distance;
}

/*#pragma mark - UINavigationBar-based actions

- (IBAction)done:(id)sender {
	UIView *tempTabBar;
	
	for (UIView *subview in self.view.subviews) {
		if (subview.tag != 0)
			[subview removeFromSuperview];
		else
			tempTabBar = subview;
	}
	UIViewController *temp;
	
	temp = [[HEWallViewController alloc] initWithNibName:@"HEWallViewController" bundle:nil];
	
	[temp.navigationController.view setHidden:YES];
	
	[self.view insertSubview:temp.view belowSubview:tempTabBar];
	
} */

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return kHESettingsTableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch ((kHESettingsTableViewSections)section) {
		case kHESettingsTableViewDistance:
			return kHESettingsTableViewDistanceNumberOfRows;
			break;
		case kHESettingsTableViewLogout:
			return kHESettingsTableViewLogoutNumberOfRows;
			break;
		case kHESettingsTableViewNumberOfSections:
			return 0;
			break;
	};
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"SettingsTableView";
	if (indexPath.section == kHESettingsTableViewDistance) {
		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
		if ( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		}
		
		// Configure the cell.
		cell.textLabel.text = [self distanceLabelForCell:indexPath];
		
		if (self.filterDistance == 0.0) {
			NSLog(@"We have a zero filter distance!");
		}
		
		HELocationAccuracy filterDistanceInFeet = self.filterDistance * ( 1 / kHEFeetToMeters);
		HELocationAccuracy distanceForCell = [self distanceForCell:indexPath];
		if (abs(distanceForCell - filterDistanceInFeet) < 0.001 ) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		
		return cell;
	} else if (indexPath.section == kHESettingsTableViewLogout) {
		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
		if ( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		}
		
		// Configure the cell.
		cell.textLabel.text = @"Log out of Anywall";
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		
		return cell;
	}
	else {
		return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch ((kHESettingsTableViewSections)section) {
		case kHESettingsTableViewDistance:
			return @"Search Distance";
			break;
		case kHESettingsTableViewLogout:
			return @"";
			break;
		case kHESettingsTableViewNumberOfSections:
			return @"";
			break;
	}
}

#pragma mark - UITableViewDelegate methods

// Called after the user changes the selection.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kHESettingsTableViewDistance) {
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];
		
		// if we were already selected, bail and save some work.
		UITableViewCell *selectedCell = [aTableView cellForRowAtIndexPath:indexPath];
		if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark) {
			return;
		}
		
		// uncheck all visible cells.
		for (UITableViewCell *cell in [aTableView visibleCells]) {
			if (cell.accessoryType != UITableViewCellAccessoryNone) {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
		selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
		
		HELocationAccuracy distanceForCellInFeet = [self distanceForCell:indexPath];
		self.filterDistance = distanceForCellInFeet * kHEFeetToMeters;
	} else if (indexPath.section == kHESettingsTableViewLogout) {
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log out of Anywall?" message:nil delegate:self cancelButtonTitle:@"Log out" otherButtonTitles:@"Cancel", nil];
		[alertView show];
	}
}

#pragma mark - UIAlertViewDelegate methods

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == kHESettingsLogoutDialogLogout) {
		// Log out.
		[PFUser logOut];
		
		[self.presentingViewController dismissModalViewControllerAnimated:YES];
		
		HEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		[appDelegate presentWelcomeViewController];
	} else if (buttonIndex == kHESettingsLogoutDialogCancel) {
		return;
	}
}

// Nil implementation to avoid the default UIAlertViewDelegate method, which says:
// "Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button"
// Since we have "Log out" at the cancel index (to get it out from the normal "Ok whatever get this dialog outta my face"
// position, we need to deal with the consequences of that.
- (void)alertViewCancel:(UIAlertView *)alertView {
	return;
}

@end
