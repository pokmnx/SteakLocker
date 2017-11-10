//
//  SignInController.h
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WifiSetupStartController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UILabel *labelDesc;
@property (nonatomic, strong) UIButton *btnNext;



@end

