//
//  MyLogCell.m
//  HuntersEdge
//
//  Created by James Forkey on 3/8/14.
//  Copyright (c) 2014 Parse. All rights reserved.
//

#import "MyLogCell.h"

@implementation MyLogCell
@synthesize titleString, dateTime, smallImageView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

@end
