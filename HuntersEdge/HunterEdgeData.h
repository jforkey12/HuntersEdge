//
//  HunterEdgeData.h
//  HunterEdges
//
//  Created by James Forkey on 8/9/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HunterEdgeData : NSObject

@property (strong) NSString *title;
@property (assign) float rating;
@property (strong) NSString *dateTime;

- (id)initWithTitle:(NSString*)title rating:(float)rating;

@end
