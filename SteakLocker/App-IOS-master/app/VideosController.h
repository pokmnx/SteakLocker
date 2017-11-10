//
//  ProfileController.h
//  Steak Locker
//
//  Created by Jared Ashlock on 10/24/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#ifndef Steak_Locker_VideosController_h
#define Steak_Locker_VideosController_h

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "XLForm.h"
#import "DropMenu.h"
#import "MBProgressHUD.h"

@class MGScrollView;

@interface VideosController : UIViewController

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) MBProgressHUD *hudMsg;

@property (nonatomic, strong) MGScrollView *scroller;

@property (nonatomic, strong) DropMenu *theMenu;
- (IBAction)onMenu: (id)sender;

@end

#endif
