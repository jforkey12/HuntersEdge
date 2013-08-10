//
//  EntryView.h
//  CustomView
//
//  Created by James Forkey.
//  Copyright (c). All rights reserved.
//

#import <UIKit/UIKit.h>

@class EntryView;

@protocol EntryViewDelegate
- (void)entryView:(EntryView *)entryView ratingDidChange:(float)rating;
@end

@interface EntryView : UIView

@property (strong, nonatomic) UIImage *notSelectedImage;
@property (strong, nonatomic) UIImage *halfSelectedImage;
@property (strong, nonatomic) UIImage *fullSelectedImage;
@property (assign, nonatomic) float rating;
@property (assign) BOOL editable;
@property (strong) NSMutableArray * imageViews;
@property (assign, nonatomic) int maxRating;
@property (assign) int midMargin;
@property (assign) int leftMargin;
@property (assign) CGSize minImageSize;
@property (assign) id <EntryViewDelegate> delegate;

@end
