//
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



@implementation SLUserObject

@dynamic user;
@dynamic device;
@dynamic object;
@dynamic vendor;
@dynamic customVendor;
@dynamic days;
@dynamic weight;
@dynamic cost;
@dynamic nickname;
@dynamic finishedAt;
@dynamic active;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"UserObject";
}


- (long)getTotalDays
{
    return self.days;
}
- (int)getDaysLeft
{
    int left = (int)[self getTotalDays];
    int curr = MIN([self getCurrentDay], left);
    return left - curr;
}
- (int)getCurrentDay
{
    NSDate *now = [NSDate date];
    
    NSTimeInterval secs = [now timeIntervalSinceDate: self.createdAt];
    int days = (int)floorf(secs / (60*60*24));
    
    if (days < 1) {
        days = 1;
    }
    
    return days;
}

- (NSString*)getDaysLeftString
{
    NSString * value;
    int left = [self getDaysLeft];
    if (left == 1) {
        value = @"1 day left";
    }
    else {
        value = [NSString stringWithFormat:@"%d days left", left];
    }
    return value;
}


- (void)initFinishedAt
{
    NSDate *now = [NSDate date];
    
    // set up date components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay: self.days];
    
    // create a calendar
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    self.finishedAt = [gregorian dateByAddingComponents:components toDate:now options:0];
}

- (void) onBeforeSave
{
    [self initFinishedAt];
    self.active = YES;
}
@end
