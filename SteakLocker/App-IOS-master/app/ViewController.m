//
//  ViewController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "ELA.h"
#import "SLModels.h"
#include <sys/sysctl.h>

@interface ViewController ()

@end

@implementation ViewController

@synthesize sb;
@synthesize vc;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    PFUser *user = [PFUser currentUser];
    sb = nil;
    vc = nil;

    [self.view setBackgroundColor:[ELA getColorBGLight]];

    if (user) {
        [ELA onUserSet: NO];
        if ([ELA hasInternet]) {
            [ELA loadUserDevices:^(NSArray * objects, NSError * error) {
                int count = [ELA getDeviceCount];
                if (count > 0) {
                    [ELA loadStoryboard:self storyboard:@"Dashboard" animated:YES];
                }
                else {
                    [ELA startAddNewDevice:self];
                }
            }];
            
            [ELA syncStuff];
            // MARK: - Uncomment this to easily get to the Notifications screen
//            [ELA loadStoryboard:self storyboard:@"Notifications" animated:YES];
        }
        else {
            [ELA startAddNewDevice:self];
        }
        
    }
    else {
        [ELA loadStoryboard:self storyboard:@"Auth" animated:NO];
    }
}

@end
