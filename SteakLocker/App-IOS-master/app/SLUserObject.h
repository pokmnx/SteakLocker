//
//  Steak Locker
//
//  Created by Jared Ashlock on 10/23/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <Parse/Parse.h>
#import "SLModels.h"

@interface SLUserObject : PFObject<PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) PFUser *user;
@property (retain) PFObject *device;
@property (retain) SLObject *object;
@property (retain) PFObject *vendor;
@property (retain) NSString *customVendor;
@property long days;
@property float cost;
@property float weight;
@property (retain) NSString *nickname;
@property (retain) NSDate *finishedAt;
@property BOOL active;

- (long)getTotalDays;
- (int)getCurrentDay;
- (int)getDaysLeft;
- (NSString *)getDaysLeftString;
- (void)initFinishedAt;
- (void)onBeforeSave;


@end

