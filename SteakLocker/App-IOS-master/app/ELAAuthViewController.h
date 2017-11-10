//
//  ELAAuthViewController.h
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignInController.h"
#import <Bolts/Bolts.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface ELAAuthViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIImageView *bg;
@property (strong, nonatomic) IBOutlet UIImageView *headerLogo;
@property (strong, nonatomic) SignInController *signInView;

@property (nonatomic, strong) UIButton *btnFB;
@property (nonatomic, strong) UIButton *btnEmail;
@property (nonatomic, strong) UILabel  *btnLogin;


- (void) slideScreen: (BOOL)slideUp;


@end

