//
//  HEWallPostsTableViewController.m
//  Hunter's Edge
//
//  Created by James Forkey on 2/6/12.
//  Copyright (c) 2013 HF Development. All rights reserved.
//

static CGFloat const kHEWallPostTableViewFontSize = 12.f;
static CGFloat const kHEWallPostTableViewCellWidth = 230.f; // subject to change.

// Cell dimension and positioning constants
static CGFloat const kHECellPaddingTop = 5.0f;
static CGFloat const kHECellPaddingBottom = 1.0f;
static CGFloat const kHECellPaddingSides = 0.0f;
static CGFloat const kHECellTextPaddingTop = 6.0f;
static CGFloat const kHECellTextPaddingBottom = 5.0f;
static CGFloat const kHECellTextPaddingSides = 5.0f;

static CGFloat const kHECellUsernameHeight = 15.0f;
static CGFloat const kHECellBkgdHeight = 32.0f;
static CGFloat const kHECellBkgdOffset = kHECellBkgdHeight - kHECellUsernameHeight;

// TableViewCell ContentView tags
static NSInteger kHECellBackgroundTag = 2;
static NSInteger kHECellTextLabelTag = 3;
static NSInteger kHECellNameLabelTag = 4;


static NSUInteger const kHETableViewMainSection = 0;

#import "HEWallPostsTableViewController.h"

#import "HEAppDelegate.h"

@interface HEWallPostsTableViewController ()

// NSNotification callbacks
- (void)distanceFilterDidChange:(NSNotification *)note;
- (void)locationDidChange:(NSNotification *)note;
- (void)postWasCreated:(NSNotification *)note;

@end

@implementation HEWallPostsTableViewController

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kHEFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kHELocationChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kHEPostCreatedNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	if (self) {
		// Customize the table:

		// The className to query on
		self.parseClassName = kHEParsePostsClassKey;

		// The key of the PFObject to display in the label of the default cell style
		self.textKey = kHEParseTextKey;

        // Whether the built-in pull-to-refresh is enabled
        if (NSClassFromString(@"UIRefreshControl")) {
            self.pullToRefreshEnabled = NO;
        } else {
            self.pullToRefreshEnabled = YES;
        }
		
		// Whether the built-in pagination is enabled
		self.paginationEnabled = YES;

		// The number of objects to show per page
		self.objectsPerPage = kHEWallPostsSearch;
	}
	return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	if (NSClassFromString(@"UIRefreshControl")) {
        // Use the new iOS 6 refresh control.
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor colorWithRed:118.0f/255.0f green:117.0f/255.0f blue:117.0f/255.0f alpha:1.0f];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.pullToRefreshEnabled = NO;
    }
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceFilterDidChange:) name:kHEFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kHELocationChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWasCreated:) name:kHEPostCreatedNotification object:nil];
	
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorColor = [UIColor clearColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
    if (NSClassFromString(@"UIRefreshControl")) {
        [self.refreshControl endRefreshing];
    }
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
	PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];

	// If no objects are loaded in memory, we look to the cache first to fill the table
	// and then subsequently do a query against the network.
	if ([self.objects count] == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}

	// Query for posts near our current location.

	// Get our current location:
	HEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	CLLocation *currentLocation = appDelegate.currentLocation;
	CLLocationAccuracy filterDistance = appDelegate.filterDistance;

	// And set the query to look by location
	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
	[query whereKey:kHEParseLocationKey nearGeoPoint:point withinKilometers:filterDistance / kHEMetersInAKilometer];
	[query includeKey:kHEParseUserKey];

	return query;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object. 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
	// Reuse identifiers for left and right cells
	static NSString *RightCellIdentifier = @"RightCell";
	static NSString *LeftCellIdentifier = @"LeftCell";

	// Try to reuse a cell
	BOOL cellIsRight = [[[object objectForKey:kHEParseUserKey] objectForKey:kHEParseUsernameKey] isEqualToString:[[PFUser currentUser] username]];
	UITableViewCell *cell;
	if (cellIsRight) { // User's post so create blue bubble
		cell = [tableView dequeueReusableCellWithIdentifier:RightCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RightCellIdentifier];
			
			UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"blueBubble.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 11.0f, 16.0f, 11.0f)]];
			[backgroundImage setTag:kHECellBackgroundTag];
			[cell.contentView addSubview:backgroundImage];

			UILabel *textLabel = [[UILabel alloc] init];
			[textLabel setTag:kHECellTextLabelTag];
			[cell.contentView addSubview:textLabel];
			
			UILabel *nameLabel = [[UILabel alloc] init];
			[nameLabel setTag:kHECellNameLabelTag];
			[cell.contentView addSubview:nameLabel];
		}
	} else { // Someone else's post so create gray bubble
		cell = [tableView dequeueReusableCellWithIdentifier:LeftCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LeftCellIdentifier];
			
			UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"grayBubble.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 11.0f, 16.0f, 11.0f)]];
			[backgroundImage setTag:kHECellBackgroundTag];
			[cell.contentView addSubview:backgroundImage];

			UILabel *textLabel = [[UILabel alloc] init];
			[textLabel setTag:kHECellTextLabelTag];
			[cell.contentView addSubview:textLabel];
			
			UILabel *nameLabel = [[UILabel alloc] init];
			[nameLabel setTag:kHECellNameLabelTag];
			[cell.contentView addSubview:nameLabel];
		}
	}
	
	// Configure the cell content
	UILabel *textLabel = (UILabel*) [cell.contentView viewWithTag:kHECellTextLabelTag];
	textLabel.text = [object objectForKey:kHEParseTextKey];
	textLabel.lineBreakMode = UILineBreakModeWordWrap;
	textLabel.numberOfLines = 0;
	textLabel.font = [UIFont systemFontOfSize:kHEWallPostTableViewFontSize];
	textLabel.textColor = [UIColor whiteColor];
	textLabel.backgroundColor = [UIColor clearColor];
	
	NSString *username = [NSString stringWithFormat:@"- %@",[[object objectForKey:kHEParseUserKey] objectForKey:kHEParseUsernameKey]];
	UILabel *nameLabel = (UILabel*) [cell.contentView viewWithTag:kHECellNameLabelTag];
	nameLabel.text = username;
	nameLabel.font = [UIFont systemFontOfSize:kHEWallPostTableViewFontSize];
	nameLabel.backgroundColor = [UIColor clearColor];
	if (cellIsRight) {
		nameLabel.textColor = [UIColor colorWithRed:175.0f/255.0f green:172.0f/255.0f blue:172.0f/255.0f alpha:1.0f];
		nameLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.35f];
		nameLabel.shadowOffset = CGSizeMake(0.0f, 0.5f);
	} else {
		nameLabel.textColor = [UIColor blackColor];
		nameLabel.shadowColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:0.35f];
		nameLabel.shadowOffset = CGSizeMake(0.0f, 0.5f);
	}
	
	UIImageView *backgroundImage = (UIImageView*) [cell.contentView viewWithTag:kHECellBackgroundTag];
	
	// Move cell content to the right position
	// Calculate the size of the post's text and username
	CGSize textSize = [[object objectForKey:kHEParseTextKey] sizeWithFont:[UIFont systemFontOfSize:kHEWallPostTableViewFontSize] constrainedToSize:CGSizeMake(kHEWallPostTableViewCellWidth, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	CGSize nameSize = [username sizeWithFont:[UIFont systemFontOfSize:kHEWallPostTableViewFontSize] forWidth:kHEWallPostTableViewCellWidth lineBreakMode:UILineBreakModeTailTruncation];
	
	
	CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath]; // Get the height of the cell
	CGFloat textWidth = textSize.width > nameSize.width ? textSize.width : nameSize.width; // Set the width to the largest (text of username)
	
	// Place the content in the correct position depending on the type
	if (cellIsRight) {
		[nameLabel setFrame:CGRectMake(self.tableView.frame.size.width-textWidth-kHECellTextPaddingSides-kHECellPaddingSides, 
									   kHECellPaddingTop+kHECellTextPaddingTop+textSize.height, 
									   nameSize.width, 
									   nameSize.height)];
		[textLabel setFrame:CGRectMake(self.tableView.frame.size.width-textWidth-kHECellTextPaddingSides-kHECellPaddingSides, 
									   kHECellPaddingTop+kHECellTextPaddingTop, 
									   textSize.width, 
									   textSize.height)];		
		[backgroundImage setFrame:CGRectMake(self.tableView.frame.size.width-textWidth-kHECellTextPaddingSides*2-kHECellPaddingSides, 
											 kHECellPaddingTop, 
											 textWidth+kHECellTextPaddingSides*2, 
											 cellHeight-kHECellPaddingTop-kHECellPaddingBottom)];
		
	} else {
		[nameLabel setFrame:CGRectMake(kHECellTextPaddingSides-kHECellPaddingSides, 
									   kHECellPaddingTop+kHECellTextPaddingTop+textSize.height, 
									   nameSize.width, 
									   nameSize.height)];
		[textLabel setFrame:CGRectMake(kHECellPaddingSides+kHECellTextPaddingSides, 
									   kHECellPaddingTop+kHECellTextPaddingTop, 
									   textSize.width, 
									   textSize.height)];
		[backgroundImage setFrame:CGRectMake(kHECellPaddingSides, 
											 kHECellPaddingTop, 
											 textWidth+kHECellTextPaddingSides*2, 
											 cellHeight-kHECellPaddingTop-kHECellPaddingBottom)];
	}

	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForNextPageAtIndexPath:indexPath];
	cell.textLabel.font = [cell.textLabel.font fontWithSize:kHEWallPostTableViewFontSize];
	return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// call super because we're a custom subclass.
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Account for the load more cell at the bottom of the tableview if we hit the pagination limit:
	if ( (NSUInteger)indexPath.row >= [self.objects count]) {
		return [tableView rowHeight];
	}

	// Retrieve the text and username for this row:
	PFObject *object = [self.objects objectAtIndex:indexPath.row];
	HEPost *postFromObject = [[HEPost alloc] initWithPFObject:object];
	NSString *text = postFromObject.title;
	NSString *username = postFromObject.user.username;
	
	// Calculate what the frame to fit the post text and the username
	CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:kHEWallPostTableViewFontSize] constrainedToSize:CGSizeMake(kHEWallPostTableViewCellWidth, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	CGSize nameSize = [username sizeWithFont:[UIFont systemFontOfSize:kHEWallPostTableViewFontSize] forWidth:kHEWallPostTableViewCellWidth lineBreakMode:UILineBreakModeTailTruncation];

	// And return this height plus cell padding and the offset of the bubble image height (without taking into account the text height twice)
	CGFloat rowHeight = kHECellPaddingTop + textSize.height + nameSize.height + kHECellBkgdOffset;
	return rowHeight;
}


#pragma mark - HEWallViewControllerSelection

- (void)highlightCellForPost:(HEPost *)post {
	// Find the cell matching this object.
	for (PFObject *object in [self objects]) {
		HEPost *postFromObject = [[HEPost alloc] initWithPFObject:object];
		if ([post equalToPost:postFromObject]) {
			// We found the object, scroll to the cell position where this object is.
			NSUInteger index = [[self objects] indexOfObject:object];

			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:kHETableViewMainSection];
			[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
			[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

			return;
		}
	}

	// Don't scroll for posts outside the search radius.
	if ([post.title compare:kHEWallCantViewPost] != NSOrderedSame) {
		// We couldn't find the post, so scroll down to the load more cell.
		NSUInteger rows = [self.tableView numberOfRowsInSection:kHETableViewMainSection];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(rows - 1) inSection:kHETableViewMainSection];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)unhighlightCellForPost:(HEPost *)post {
	// Deselect the post's row.
	for (PFObject *object in [self objects]) {
		HEPost *postFromObject = [[HEPost alloc] initWithPFObject:object];
		if ([post equalToPost:postFromObject]) {
			NSUInteger index = [[self objects] indexOfObject:object];
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

			return;
		}
	}
}


#pragma mark - ()

- (void)distanceFilterDidChange:(NSNotification *)note {
	[self loadObjects];
}

- (void)locationDidChange:(NSNotification *)note {
	[self loadObjects];
}

- (void)postWasCreated:(NSNotification *)note {
	[self loadObjects];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}

@end
