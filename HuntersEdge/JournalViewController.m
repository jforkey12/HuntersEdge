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
@synthesize animals = _animals;

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
    
}

- (void)addTapped:(id)sender {
    HunterEdgeDoc *newDoc = [[HunterEdgeDoc alloc] initWithTitle:@"New Entry" rating:0 thumbImage:nil fullImage:nil];
    [_animals addObject:newDoc];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_animals.count-1 inSection:0];
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
        [_animals removeObjectAtIndex:indexPath.row];
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
    return [self.animals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"MyBasicCell"];
    HunterEdgeDoc *animal = [self.animals objectAtIndex:indexPath.row];
	if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyBasicCell"];
    }
    cell.textLabel.text = animal.data.title;
    cell.imageView.image = animal.thumbImage;
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
    HunterEdgeDoc *animal = [self.animals objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    detailController.detailItem = animal;
	[self.view addSubview:detailController.view];
}


@end
