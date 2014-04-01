//
//  HunterEdgeData.m
//  HunterEdges
//
//  Created by James Forkey on 8/9/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "HunterEdgeData.h"

@implementation HunterEdgeData

@synthesize title = _title;
@synthesize rating = _rating;
@synthesize dateTime = _dateTime;

- (id)initWithTitle:(NSString*)title rating:(float)rating {
    if ((self = [super init])) {
        self.title = title;
        self.rating = rating;
		self.dateTime = _dateTime;
    }
    return self;
}

@end
