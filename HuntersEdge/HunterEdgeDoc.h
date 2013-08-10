//
//  HunterEdgeDoc.h
//  HunterEdges
//
//  Created by James Forkey on 8/9/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HunterEdgeData;

@interface HunterEdgeDoc : NSObject

@property (strong) HunterEdgeData *data;
@property (strong) UIImage *thumbImage;
@property (strong) UIImage *fullImage;

- (id)initWithTitle:(NSString*)title rating:(float)rating thumbImage:(UIImage *)thumbImage fullImage:(UIImage *)fullImage;

@end
