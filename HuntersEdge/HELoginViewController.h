//
//  HELoginViewController.h
//  Hunter's Edge
//
//  Created by James Forkey on 2/1/12.
//  Copyright (c) 2013 HF Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HELoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *facebookButton;

@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
