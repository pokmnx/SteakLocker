
//
//  SignInController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

@import UIKit;
#import "SetupController.h"
#import "ELA.h"

@interface SetupController ()

@end

@implementation SetupController

@synthesize iconFile;
@synthesize titleLabel;
@synthesize nextLabel;

@synthesize icon;
@synthesize labelTitle;
@synthesize btnNext;

UIImageView *navBarHairlineImageView;


- (IBAction)onNext
{
    [self goNext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];

    [self.navigationController setTitle: @"Setup"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    navBarHairlineImageView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    navBarHairlineImageView.hidden = NO;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)goNext
{
    [self performSegueWithIdentifier:@"segueWifi" sender:self];
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
