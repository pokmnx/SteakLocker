
//
//  SignInController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

@import UIKit;
#import "WifiSetupStartController.h"
#import "ELA.h"
#import "ELADevice.h"

@interface WifiSetupStartController ()

@end

@implementation WifiSetupStartController


- (IBAction)onNext
{
    [self goNext];
}

- (void)onCancel
{
    [ELA dismissStoryboard:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    
    [cancelButton setTintColor:[ELA getColorAccent]];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    
    [super viewWillAppear:animated];
}



- (void)viewDidLoad {

    int yOffset = 250;

    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    CGRect scrn = [[UIScreen mainScreen] bounds];
    
    
    [self.navigationController setTitle: @"Connect to Network"];
    [self.view setBackgroundColor: [ELA getColorBGLight]];
    
    CGRect rect = CGRectMake(15, 25, scrn.size.width-30, 25);
    self.labelTitle = [[UILabel alloc] initWithFrame: rect];
    [self.labelTitle setFont: [ELA getFontThin: 20]];
    self.labelTitle.text = @"Connect to Network";
    [self.labelTitle setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview: self.labelTitle];
    
    
    self.icon = [ELA addImage:@"IconWifiConnect" X:(scrn.size.width - 150)/2 Y:65 W:150 H:150];
    [self.view addSubview: self.icon];
    self.icon.userInteractionEnabled = NO;
    
    rect = CGRectMake(38, 250, scrn.size.width-76, 100);
    self.labelDesc = [[UILabel alloc] initWithFrame: rect];
    [self.labelDesc setFont: [ELA getFontMedium: 15]];
    self.labelDesc.text = @"Tap the connect button below and connect to the Steak Locker Wi-Fi network.";
    [self.labelDesc setTextAlignment:NSTextAlignmentCenter];
    [self.labelDesc setNumberOfLines:0 ];
    [self.view addSubview: self.labelDesc];
    
    
    
    self.btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnNext setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    UIImage *bg = [ELA imageWithColor: [ELA getColorAccent]];
    [self.btnNext setBackgroundImage:bg forState:UIControlStateNormal];
    
    UIColor *color = [UIColor colorWithRed: 153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    UIImage *bgOff = [ELA imageWithColor: color];
    [self.btnNext setBackgroundImage:bgOff forState:UIControlStateDisabled];
    
    [self.btnNext setTitle:@"Connect" forState: UIControlStateNormal];
    [self.btnNext setFrame: CGRectMake(25, yOffset+150, scrn.size.width-50, 60)];
    
    [self.btnNext setClipsToBounds:YES];
    self.btnNext.layer.cornerRadius = 30;
    self.btnNext.layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.0f].CGColor;
    
    [self.btnNext addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.btnNext];
    
}


- (void)goNext
{
    [self performSegueWithIdentifier:@"segueWifiConnect" sender:self];

    ELADevice *elaDevice = [ELA getElaDevice];
    
    if (![elaDevice isConnectedToDeviceWifi]) {
        [ELA openWifiSettings];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue names in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"segueWifiConnect"])
    {
        /*
        // Get reference to the destination view controller
        SetupSyncController *vc = [segue destinationViewController];
        vc.ssid = inputSsid.text;
        vc.pass = inputPass.text;
         */
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
