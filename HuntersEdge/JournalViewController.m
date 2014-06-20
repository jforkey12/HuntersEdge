//
//  JournalViewController.m
//  Hunter's Edge
//
//  Created by James Forkey on 8/9/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "JournalViewController.h"
#import "HunterEdgeDoc.h"
#import "HunterEdgeData.h"
#import "JournalDetailViewController.h"

@implementation JournalViewController
@synthesize myLogs = _myLogs;
@synthesize theImage;
@synthesize thePFImage;
@synthesize date;
@synthesize dateFormat;
@synthesize theimageData;
@synthesize journalDetail;


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	
    [super viewDidLoad];
	
	self.title = @"Hunting Journal";
    self.navigationController.view.hidden = NO;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                              target:self action:@selector(addTapped:)];
	
	[self.tableView setContentInset:UIEdgeInsetsMake(20,0,0,0)];
	[self.tableView reloadData];
	 }

- (void)addTapped:(id)sender {
    HunterEdgeDoc *newDoc = [[HunterEdgeDoc alloc] initWithTitle:@"New Entry" rating:0 thumbImage:nil fullImage:nil];
    [_myLogs addObject:newDoc];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_myLogs.count-1 inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:YES];
    
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
		JournalDetailViewController *journalVC = [[JournalDetailViewController alloc] initWithNibName:@"JournalDetailViewController" bundle:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	//We must initialize all the variables we are going to use
	date = [[NSDate alloc] init];
	dateFormat = [[NSDateFormatter alloc] init];
	theImage = [[UIImage alloc] init];
	thePFImage = [[PFFile alloc] init];
	theimageData = [[NSData alloc] init];
	
	[self loadMyJournal];
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)loadMyJournal{
	//query to get the logs from parse
	PFQuery *query = [PFQuery queryWithClassName:@"logEntries"];
//	[query whereKey:@"user" equalTo:[PFUser currentUser]];
	
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
			self.myLogs = [[NSMutableArray alloc] initWithArray:objects];
			// The find succeeded.
			NSLog(@"Successfully retrieved %d log entries.", objects.count);

			dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
			});
		} else {
			// Log details of the failure
			NSLog(@"Error: %@ %@", error, [error userInfo]);
		}
		
	}];

}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {        
        [_myLogs removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }  
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	NSLog(@"numberofRowsinSection: %d", [_myLogs count]);
    return [_myLogs count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	MyLogCell *cell = (MyLogCell *) [tableView dequeueReusableCellWithIdentifier:@"MyLogCell"];
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MyLogCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (MyLogCell *)currentObject;
                break;
            }
        }
    }
	
    PFObject *myLog = [_myLogs objectAtIndex:indexPath.row];
	HunterEdgeDoc *entry = [[HunterEdgeDoc alloc] initWithTitle:[myLog objectForKey:@"title"] rating:4 thumbImage:[UIImage imageNamed:@"doe.jpg"] fullImage:[UIImage imageNamed:@"doe.jpg"]];

	[dateFormat setDateFormat:@"EEE, MMM, yyyy hh:mm a"];
	
	NSString *dateTime = [dateFormat stringFromDate:[myLog createdAt]];
	
	NSLog(@"datetime: %@", dateTime);

	[cell.titleString setText:entry.data.title];
	[cell.dateTime setText:dateTime];

    return cell;
	
}

#pragma mark - UITableViewDelegate methods

// Called after the user changes the selection.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	for (UIView *subview in self.view.subviews) {
		if (subview.tag != 0)
			[subview removeFromSuperview];
	}
	
	JournalDetailViewController *detailController = [[JournalDetailViewController alloc] initWithNibName:@"JournalDetailViewController" bundle:nil];
	PFObject *pfLog = [_myLogs objectAtIndex:indexPath.row];
	theimageData = [pfLog objectForKey:@"picture"];
//	t = [thePFImage getData];
//	theImage = [UIImage imageWithData:theimageData];
	
	UIImage *image = [UIImage imageWithData:theimageData];

	HunterEdgeDoc *myLog = [[HunterEdgeDoc alloc] initWithTitle:[pfLog objectForKey:@"title" ] rating:1 thumbImage:nil  fullImage:nil];
	[myLog setThumbImage:image];
	
	
	
//    HunterEdgeDoc *myLog = [self.myLogs objectAtIndex:self.tableView.indexPathForSelectedRow.row];
//    detailController.detailItem = myLog;
	[self.view addSubview:detailController.view];
	[detailController.imageView setImage:image];
	NSDate *temp = [pfLog objectForKey:@"createdAt"];
	[dateFormat setDateFormat:@"EEE, MMM, yyyy hh:mm a"];
	
	NSString *dateTime = [dateFormat stringFromDate:[pfLog createdAt]];

	 NSLog(@"datetime: %@", dateTime);
	[detailController.dateLabel setText:dateTime];

}



@end
