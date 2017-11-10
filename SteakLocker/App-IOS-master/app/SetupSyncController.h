//
//  SignInController.h
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetupController.h"
#import <BlinkUp/BlinkUp.h>

@interface SetupSyncController : SetupController


@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *pass;
@property (nonatomic, strong) UILabel *desc;
@property (nonatomic, strong) UIButton *btnTroubleshoot;
@property (nonatomic, strong) UIButton *btnSync;
@property (nonatomic, strong) UIButton *btnClear;

@property (nonatomic, strong) UILabel *title2;
@property (nonatomic, strong) UILabel *desc2;
@property (nonatomic, strong) UIImageView *imagePower;
@property (nonatomic, strong) UIImageView *imageBlink;

- (void) flashSSID;
//- (IBAction)flashWPS;
- (IBAction)flashClearConfig;

- (IBAction)onTroubleshoot;

@end

