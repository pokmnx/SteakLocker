//
//  SupportController.h
//  Steak Locker
//
//  Created by Jared Ashlock on 10/24/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#ifndef Steak_Locker_SupportController_h
#define Steak_Locker_SupportController_h

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "DropdownController.h"

@interface SupportController : DropdownController

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UILabel *desc;
@property (nonatomic, strong) UIButton *btnEmail;

- (IBAction)onEmail;
- (IBAction)onMenu: (id)sender;
@end

#endif
