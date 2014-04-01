//
//  MyLogCell.h
//  HuntersEdge
//
//  Created by James Forkey on 3/8/14.
//  Copyright (c) 2014 Hunter's Edge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyLogCell : UITableViewCell
{
    IBOutlet UILabel *titleString;
	IBOutlet UILabel *dateTime;
	IBOutlet UIImageView *smallImageView;
}

@property (nonatomic,strong) IBOutlet UILabel *titleString;
@property (nonatomic,strong) IBOutlet UILabel *dateTime;
@property (nonatomic,strong) IBOutlet UIImageView *smallImageView;

@end