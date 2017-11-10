
//
//  SignInController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

@import UIKit;
#import "SetupCompleteController.h"
#import "ELA.h"

@interface SetupCompleteController ()

@end

@implementation SetupCompleteController

@synthesize icon;
@synthesize title;
@synthesize desc;
@synthesize btnNext;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect scrn = [[UIScreen mainScreen] bounds];
    
    [self.view setBackgroundColor: [ELA getColorBGLight]];
    
    btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [btnNext setBackgroundColor: [ELA getColorAccent]];
    [btnNext setTitle:@"Take me to my dashboard" forState: UIControlStateNormal];
    [btnNext setFrame: CGRectMake(0, scrn.size.height-60, scrn.size.width, 60)];
    [btnNext addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: btnNext];
}

- (IBAction)onNext
{
    [self goNext];
}

- (void)goNext
{
    [ELA reloadUserDevices:^(NSArray * objects, NSError * error) {
        
        [ELA loadStoryboard:self storyboard:@"Dashboard" animated:NO];
        
        
    }];
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
