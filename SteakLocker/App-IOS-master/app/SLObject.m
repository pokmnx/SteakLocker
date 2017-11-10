//
//  SLObject.m
//  Steak Locker
//
//  Created by Jared Ashlock on 10/23/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <Foundation/Foundation.h>
// Import this header to let Armor know that PFObject privately provides most
// of the methods for PFSubclassing.
#import <Parse/PFObject+Subclass.h>


#import "SLModels.h"
#import "ELA.h"


@implementation SLObject

@dynamic type;
@dynamic title;
@dynamic active;
@dynamic image;

@dynamic defaultDays;

@dynamic servingSize;
@dynamic calories;
@dynamic caloriesFromFat;
@dynamic totalFat;
@dynamic saturatedFat;
@dynamic transFat;
@dynamic cholesterol;
@dynamic sodium;
@dynamic carbohydrates;
@dynamic dietaryFiber;
@dynamic sugars;
@dynamic protein;
@dynamic vitaminA;
@dynamic vitaminC;
@dynamic calcium;
@dynamic iron;
@dynamic information;



+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Object";
}

- (NSString*)getAgingType
{
    return ([self.type isEqualToString: TYPE_CHARCUTERIE]) ? TYPE_CHARCUTERIE : TYPE_DRYAGING;
}

@end