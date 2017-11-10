//
//  SupportController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import "SupportController.h"
#import <Parse/Parse.h>
#import "ELA.h"

@interface SupportController ()

@end

@implementation SupportController

@synthesize labelTitle;
@synthesize desc;
@synthesize btnEmail;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect scrn = [[UIScreen mainScreen] bounds];
    labelTitle = [[UILabel alloc] initWithFrame: CGRectMake(0, 100, scrn.size.width, 30)];
    desc = [[UILabel alloc] initWithFrame: CGRectMake(20, 150, scrn.size.width-40, 100)];
    btnEmail = [UIButton buttonWithType:UIButtonTypeCustom];
}



- (void)viewDidAppear:(BOOL)animated {
    
    [self.view setBackgroundColor:[ELA getColorBGLight]];
 
    
    // Do any additional setup after loading the view, typically from a nib.
    CGRect scrn = [[UIScreen mainScreen] bounds];
    
    [self.view setBackgroundColor: [ELA getColorBGLight]];
    
    
    [labelTitle setFont: [ELA getFontThin:25]];
    labelTitle.text = @"Have a question?";
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.textColor = [ELA getColorAccent];
    [self.view addSubview: labelTitle];
    
    

    [desc setFont: [ELA getFontThin: 14]];
    desc.text = @"Click the button to below to email us your question.";
    desc.numberOfLines = 5;
    desc.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview: desc];
    
    

    [btnEmail setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [btnEmail setBackgroundColor: [ELA getColorAccent]];
    [btnEmail setTitle:@"Support Ticket" forState: UIControlStateNormal];
    [btnEmail setFrame: CGRectMake(0, scrn.size.height-60-64, scrn.size.width, 60)];
    [btnEmail addTarget:self action:@selector(onEmail) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: btnEmail];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onEmail
{
    [ELA supportEmail];

 //

}
- (IBAction)onMenu: (id)sender
{
    self.theMenu.activeItemName = @"Support";
    if (self.theMenu.showing) {
        [self.theMenu hideMenu];
        [self.theMenu setAlpha:0.0f];
        [self.view sendSubviewToBack:self.theMenu];
    }
    else {
        [self.view bringSubviewToFront:self.theMenu];
        [self.theMenu setAlpha:1.0f];
        [self.theMenu showMenu];
    }
    
    
}


@end
