//
//  HEWallPostCreateViewController.h
//  Hunter's Edge
//
//  Created by James Forkey on 1/31/12.
//  Copyright (c) 2013 HF Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEWallPostCreateViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UILabel *characterCount;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *postButton;

- (IBAction)cancelPost:(id)sender;
- (IBAction)postPost:(id)sender;

@end
