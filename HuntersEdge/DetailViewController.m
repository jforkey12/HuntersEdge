//
//  DetailViewController.m
//  Hunter's Edge
//
//  Created by James Forkey 2013.
//  Copyright (c) 2013. All rights reserved.
//

#import "DetailViewController.h"
#import "ScaryBugDoc.h"
#import "ScaryBugData.h"
#import "UIImageExtras.h"
#import "SVProgressHUD.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize titleField = _titleField;
@synthesize entryView = _entryView;
@synthesize imageView = _imageView;
@synthesize picker = _picker;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    self.entryView.notSelectedImage = [UIImage imageNamed:@"shockedface2_empty.png"];
    self.entryView.halfSelectedImage = [UIImage imageNamed:@"shockedface2_half.png"];
    self.entryView.fullSelectedImage = [UIImage imageNamed:@"shockedface2_full.png"];
    self.entryView.editable = YES;
    self.entryView.maxRating = 5;
    self.entryView.delegate = self;
    
    if (self.detailItem) {
        self.titleField.text = self.detailItem.data.title;
        self.entryView.rating = self.detailItem.data.rating;
        self.imageView.image = self.detailItem.fullImage;
    }
    
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
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [self setTitleField:nil];
    [self setEntryView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    // Return YES for supported orientations
    return YES;
}

- (IBAction)titleFieldTextChanged:(id)sender {
    self.detailItem.data.title = self.titleField.text;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark EntryViewDelegate

- (void)entryView:(EntryView *)entryView ratingDidChange:(float)rating {
    self.detailItem.data.rating = rating;
}

- (IBAction)addPictureTapped:(id)sender {
    if (self.picker == nil) {   
        
        // 1) Show status
        [SVProgressHUD showWithStatus:@"Loading picker..."];
        
        // 2) Get a concurrent queue form the system
        dispatch_queue_t concurrentQueue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        // 3) Load picker in background
        dispatch_async(concurrentQueue, ^{
        
            self.picker = [[UIImagePickerController alloc] init];
            self.picker.delegate = self;
            self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.picker.allowsEditing = NO;    
                        
            // 4) Present picker in main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController presentModalViewController:_picker animated:YES];    
                [SVProgressHUD dismiss];
            });
            
        });        
        
    }  else {        
        [self.navigationController presentModalViewController:_picker animated:YES];    
    }
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {    
    
    [self dismissModalViewControllerAnimated:YES];
    
    UIImage *fullImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage]; 
    
    // 1) Show status
    [SVProgressHUD showWithStatus:@"Resizing image..."];
    
    // 2) Get a concurrent queue form the system
    dispatch_queue_t concurrentQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 3) Resize image in background
    dispatch_async(concurrentQueue, ^{
    
        UIImage *thumbImage = [fullImage imageByScalingAndCroppingForSize:CGSizeMake(44, 44)];
        
        // 4) Present image in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            self.detailItem.fullImage = fullImage;
            self.detailItem.thumbImage = thumbImage;
            self.imageView.image = fullImage;
            [SVProgressHUD dismiss];
        });

    });
    
}

@end
