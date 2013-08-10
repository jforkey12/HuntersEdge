//
//  HunterEdgeDoc.m
//  HunterEdges
//
//  Created by James Forkey on 8/9/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "HunterEdgeDoc.h"
#import "HunterEdgeData.h"

@implementation HunterEdgeDoc
@synthesize data = _data;
@synthesize thumbImage = _thumbImage;
@synthesize fullImage = _fullImage;

- (id)initWithTitle:(NSString*)title rating:(float)rating thumbImage:(UIImage *)thumbImage fullImage:(UIImage *)fullImage {   
    if ((self = [super init])) {
        self.data = [[HunterEdgeData alloc] initWithTitle:title rating:rating];
        self.thumbImage = thumbImage;
        self.fullImage = fullImage;
    }
    return self;
}

@end
