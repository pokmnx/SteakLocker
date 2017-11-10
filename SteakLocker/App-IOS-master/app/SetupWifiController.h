//
//  SignInController.h
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetupController.h"

@interface SetupWifiController : SetupController <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *inputSsid;
@property (nonatomic, strong) UITextField *inputPass;
@property (nonatomic, strong) UIImageView *iconSsid;
@property (nonatomic, strong) UIImageView *iconPass;
@property (nonatomic, strong) UIImageView *lineSsid;
@property (nonatomic, strong) UIImageView *linePass;



@end

