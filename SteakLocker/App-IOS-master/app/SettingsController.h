//
//  SettingsController.h
//  Steak Locker
//
//  Created by Jared Ashlock on 10/24/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#ifndef Steak_Locker_SettingsController_h
#define Steak_Locker_SettingsController_h

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "XLForm.h"
#import "DropMenu.h"
#import "MBProgressHUD.h"
#import "LockersController.h"

@interface SettingsController : XLFormViewController <XLFormDescriptorDelegate>

@property (nonatomic, strong) PFObject *userDevice;
@property (nonatomic, strong) XLFormRowDescriptor *rowDevice;
@property (nonatomic, strong) XLFormRowDescriptor *rowActive;
@property (nonatomic, strong) LockersController *parent;

@property (nonatomic) BOOL setTemperatureEnabled;
@property (nonatomic) BOOL setHumidityEnabled;

@property (nonatomic, strong) DropMenu *theMenu;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) MBProgressHUD *hudMsg;
@property (nonatomic, strong) XLFormRowDescriptor *agingTypeRow;

@property (nonatomic, strong) XLFormDescriptor *formDevice;

@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *warningOldType;
@property (nonatomic, strong) NSString *warningNewType;

- (IBAction)onMenu: (id)sender;
- (IBAction)onBack: (id)sender;


//- (void)validateCode;
@end

#endif
