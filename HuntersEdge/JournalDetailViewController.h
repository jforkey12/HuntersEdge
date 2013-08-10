//
//  JournalEntryViewController.h
//  Hunter's Edge
//
//  Created by James Forkey 2013.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntryView.h"

@class HunterEdgeDoc;

@interface JournalDetailViewController : UIViewController <UITextFieldDelegate, EntryViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) HunterEdgeDoc * detailItem;
@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet EntryView *entryView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImagePickerController * picker;

- (IBAction)addPictureTapped:(id)sender;
- (IBAction)titleFieldTextChanged:(id)sender;

@end
