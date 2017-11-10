//
//  SignInController.h
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetupController.h"


@interface SetupStartController : SetupController

@property (nonatomic, strong) UIImageView *icon;
//@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *line1;
@property (nonatomic, strong) UILabel *line2;
@property (nonatomic, strong) UIButton *btnNext;

- (IBAction)onTouchIcon:(UITapGestureRecognizer *)recognizer;

@end

