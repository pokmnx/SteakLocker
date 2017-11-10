//
//  SLObject.h
//  Steak Locker
//
//  Created by Jared Ashlock on 10/23/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <Parse/Parse.h>


@interface SLObject : PFObject<PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) NSString *type;
@property (retain) NSString *title;
@property BOOL active;
@property (retain) PFFile *image;


@property int defaultDays;
@property (retain) NSString *servingSize;
@property (retain) NSString *calories;
@property (retain) NSString *caloriesFromFat;
@property (retain) NSString *totalFat;
@property (retain) NSString *saturatedFat;
@property (retain) NSString *transFat;
@property (retain) NSString *cholesterol;
@property (retain) NSString *sodium;
@property (retain) NSString *carbohydrates;
@property (retain) NSString *dietaryFiber;
@property (retain) NSString *sugars;
@property (retain) NSString *protein;
@property (retain) NSString *vitaminA;
@property (retain) NSString *vitaminC;
@property (retain) NSString *calcium;
@property (retain) NSString *iron;
@property (retain) NSString *information;


- (NSString*)getAgingType;
@end

