//
//  SignInController.h
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetupController : UIViewController

@property (nonatomic, weak) NSString* iconFile;
@property (nonatomic, weak) NSString* titleLabel;
@property (nonatomic, weak) NSString* nextLabel;

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UIButton *btnNext;


- (UIImageView *)findHairlineImageViewUnder:(UIView *)view;

- (IBAction)onNext;


@end

