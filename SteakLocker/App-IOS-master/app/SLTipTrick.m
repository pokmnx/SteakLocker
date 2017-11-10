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



@implementation SLTipTrick

@dynamic title;
@dynamic url;
@dynamic active;
@dynamic image;
@dynamic rank;


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"TipTrick";
}
@end
