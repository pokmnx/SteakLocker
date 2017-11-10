
//
//  SignInController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

@import UIKit;
#import "SetupStartController.h"
#import "ELA.h"

@interface SetupStartController ()

@end

@implementation SetupStartController
@synthesize iconFile;
@synthesize titleLabel;
@synthesize nextLabel;
@synthesize icon;
@synthesize labelTitle;
@synthesize line1;
@synthesize line2;
@synthesize btnNext;


- (IBAction)onNext
{
    [self goNext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    iconFile = @"SetupIconStart";
    titleLabel = @"Setup";
    nextLabel = @"Let's Get Started";
    
    // Do any additional setup after loading the view, typically from a nib.
    CGRect scrn = [[UIScreen mainScreen] bounds];
    
    [self.view setBackgroundColor: [ELA getColorBGLight]];
    
    icon = [ELA addImage:iconFile X:(scrn.size.width - 100)/2 Y:65 W:100 H:100];
    [self.view addSubview: icon];
    icon.userInteractionEnabled = YES;

    UITapGestureRecognizer *tapRecognizer;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchIcon:)];
    [icon addGestureRecognizer: tapRecognizer];

    
    
    
    
    labelTitle = [[UILabel alloc] initWithFrame: CGRectMake(0, 175, scrn.size.width, 25)];
    [labelTitle setFont: [ELA getFontThin: 20]];
    labelTitle.text = titleLabel;
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.textColor = [ELA getColorAccent];
    [self.view addSubview: labelTitle];
    
    
    line1 = [[UILabel alloc] initWithFrame: CGRectMake(20, 250, scrn.size.width-40, 20)];
    [line1 setFont: [ELA getFontThin: 14]];
    line1.text = @"Welcome to Steak Locker.";
    line1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview: line1];
    
    line2 = [[UILabel alloc] initWithFrame: CGRectMake(20, 275, scrn.size.width-40, 20)];
    [line2 setFont: [ELA getFontThin: 14]];
    line2.text = @"Let’s get ready to setup your new locker.";
    line2.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview: line2];
    
    
    btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [btnNext setBackgroundColor: [ELA getColorAccent]];
    [btnNext setTitle:nextLabel forState: UIControlStateNormal];
    [btnNext setFrame: CGRectMake(0, scrn.size.height-60, scrn.size.width, 60)];
    [btnNext addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: btnNext];
    
}

- (void)goNext
{
    [self performSegueWithIdentifier:@"segueWifi" sender:self];
}

- (IBAction)onTouchIcon:(UITapGestureRecognizer *)recognizer
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Start Over"
                                                    message:@"Do you want to log out and start over?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            //do something?
            break;
        case 1: //"Yes" pressed
            //here you pop the viewController
            [ELA logOut:self];
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
