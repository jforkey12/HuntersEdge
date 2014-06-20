//
//  JournalViewController.h
//  Hunter's Edge
//
//  Created by James Forkey on 8/9/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyLogCell.h"


@interface JournalViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *myLogs;
@property (strong, nonatomic) NSDateFormatter *dateFormat;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) PFFile *thePFImage;
@property (strong, nonatomic) NSData *theimageData;
@property (strong, nonatomic) UIImage *theImage;

//AT
@property (strong, nonatomic) UITextView *journalDetail;

@end
