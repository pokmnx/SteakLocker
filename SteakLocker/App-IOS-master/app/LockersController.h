//
//  SettingsController.h
//  Steak Locker
//
//  Created by Jared Ashlock on 10/24/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "XLForm.h"
#import "DropMenu.h"
#import "MBProgressHUD.h"

@interface LockersController : XLFormViewController <XLFormDescriptorDelegate>

@property (nonatomic, strong) NSString *tempC;
@property (nonatomic, strong) NSString *tempF;
@property (nonatomic, strong) DropMenu *theMenu;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) MBProgressHUD *hudMsg;
@property (nonatomic, strong) XLFormDescriptor *formDevices;
@property (nonatomic, strong) XLFormSectionDescriptor *sectionDevices;
- (IBAction)onMenu: (id)sender;
- (IBAction)onLogout: (id)sender;

- (void) updateDevices;
//- (void)validateCode;
@end

