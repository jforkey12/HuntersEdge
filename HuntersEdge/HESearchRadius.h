//
//  HESearchRadius.h
//  Hunter's Edge
//
//  Created by James Forkey on 2/8/12.
//  Copyright (c) 2013 HF Development. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface HESearchRadius : NSObject <MKOverlay>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, assign) MKMapRect boundingMapRect;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate radius:(CLLocationDistance)radius;

@end
