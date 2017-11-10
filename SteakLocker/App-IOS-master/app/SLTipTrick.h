//

//  Steak Locker
//
//  Created by Jared Ashlock on 10/23/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <Parse/Parse.h>


@interface SLTipTrick : PFObject<PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) NSString *title;
@property (retain) NSString *url;
@property BOOL active;
@property (retain) PFFile *image;
@property int rank;

@end

