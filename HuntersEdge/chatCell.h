//
//  chatCell.h
//  Hunter's Edge
//
//  Created by James Forkey on 8/5/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface chatCell : UITableViewCell
{
    IBOutlet UILabel *userLabel;
	IBOutlet UITextView *textString;
	IBOutlet UILabel *timeLabel;
}

@property (nonatomic,strong) IBOutlet UILabel *userLabel;
@property (nonatomic,strong) IBOutlet UITextView *textString;
@property (nonatomic,strong) IBOutlet UILabel *timeLabel;

@end
