//
//  HEWallPostsTableViewController.h
//  Hunter's Edge
//
//  Created by James Forkey on 2/6/12.
//  Copyright (c) 2013 HF Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "HEWallViewController.h"

@interface HEWallPostsTableViewController : PFQueryTableViewController <HEWallViewControllerHighlight>

- (void)highlightCellForPost:(HEPost *)post;
- (void)unhighlightCellForPost:(HEPost *)post;

@end
