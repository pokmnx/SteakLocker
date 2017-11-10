//
//  SignInController.h
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInController : UIViewController <UITextFieldDelegate>


@property (nonatomic, strong) UIButton *btnSignUp;
@property (nonatomic, strong) UIButton *btnSignIn;
@property (nonatomic, strong) UIButton *btnAction;
@property (nonatomic, strong) UITextField *inputName;
@property (nonatomic, strong) UITextField *inputEmail;
@property (nonatomic, strong) UITextField *inputPass;
@property (nonatomic, strong) UIImageView *iconName;
@property (nonatomic, strong) UIImageView *iconEmail;
@property (nonatomic, strong) UIImageView *iconPass;
@property (nonatomic, strong) UIImageView *lineName;
@property (nonatomic, strong) UIImageView *lineEmail;
@property (nonatomic, strong) UIImageView *linePass;
@property (nonatomic, strong) UILabel *btnCancel;

- (void)goNext: (BOOL)newUser;

- (void)showSignUp;
- (void)showSignIn;

- (IBAction)onShowSignUp;
- (IBAction)onShowSignIn;
- (IBAction)onAction;

- (void)HandleUserAuth;

@end

