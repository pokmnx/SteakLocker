
//
//  SignInController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

@import UIKit;
#import "SetupWifiController.h"
#import "SetupSyncController.h"
#import "ELA.h"

@interface SetupWifiController ()

@end

@implementation SetupWifiController
@synthesize iconFile;
@synthesize titleLabel;
@synthesize nextLabel;
@synthesize inputSsid;
@synthesize inputPass;
@synthesize iconSsid;
@synthesize iconPass;
@synthesize lineSsid;
@synthesize linePass;

@synthesize icon;
@synthesize labelTitle;
@synthesize btnNext;


- (IBAction)onNext
{
    [self goNext];
}

- (void)onLogout
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Start Over"
                                                    message:@"Do you want to log out and start over?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];    
}

- (void)onCancel
{
    [ELA loadStoryboard:self storyboard:@"Settings" animated:YES];
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


- (void)viewWillAppear:(BOOL)animated
{
    int count = [ELA getDeviceCount];
    
    if (count > 0) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
        
        [cancelButton setTintColor:[ELA getColorAccent]];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    else {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
        
        [backButton setTintColor:[ELA getColorAccent]];
        
        self.navigationItem.leftBarButtonItem = backButton;
    }
    
    
    
    [super viewWillAppear:animated];
}



- (void)viewDidLoad {
    iconFile = @"SetupIconWifi";
    titleLabel = @"Select WiFi";
    nextLabel = @"Next";
    int yOffset = 250;

    NSString *currentSsid = nil;// [BUNetworkManager currentWifiSSID];
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    CGRect scrn = [[UIScreen mainScreen] bounds];
    
    
    [self.navigationController setTitle: @"Setup"];
    [self.view setBackgroundColor: [ELA getColorBGLight]];
    
    CGRect rect = CGRectMake(15, 25, scrn.size.width-30, 25);
    labelTitle = [[UILabel alloc] initWithFrame: rect];
    [labelTitle setFont: [ELA getFontThin: 20]];
    labelTitle.text = titleLabel;
    [self.view addSubview: labelTitle];
    
    yOffset = rect.origin.y + rect.size.height + 25;
    inputSsid = [[UITextField alloc] initWithFrame: CGRectMake( 50, yOffset+0, scrn.size.width-70, 50 )];
    inputSsid.placeholder = @"Network Name";
    
    inputSsid.text = currentSsid;
    inputSsid.delegate = self;
    [inputSsid setReturnKeyType:UIReturnKeyNext];
    
    UIView * bgWhite = [[UIView alloc] initWithFrame:CGRectMake(0,yOffset, scrn.size.width, 100)];
    [bgWhite setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bgWhite];
    [self.view sendSubviewToBack:bgWhite];
    
    
    lineSsid = [ELA addImage:@"InputLine" X:0 Y:yOffset-1 W:scrn.size.width H:1];
    [self.view addSubview: lineSsid];
    
    [self.view addSubview: inputSsid];
    iconSsid = [ELA addImage:@"IconWifi" X:0 Y:yOffset+0 W:50 H:50];
    [self.view addSubview: iconSsid];
    lineSsid = [ELA addImage:@"InputLine" X:0 Y:yOffset+50 W:scrn.size.width H:1];
    [self.view addSubview: lineSsid];
    
    
    inputPass = [[UITextField alloc] initWithFrame: CGRectMake( 50, yOffset+50, 260, 50 )];
    inputPass.placeholder = @"Password If Required";
    inputPass.delegate = self;
    inputPass.secureTextEntry = true;
    [inputPass setReturnKeyType:UIReturnKeyGo];
    [self.view addSubview: inputPass];
    iconPass = [ELA addImage:@"IconPass" X:0 Y:yOffset+50 W:50 H:50];
    [self.view addSubview: iconPass];
    linePass = [ELA addImage:@"InputLine" X:0 Y:yOffset+100 W:scrn.size.width H:1];
    [self.view addSubview: linePass];

    btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    UIImage *bg = [ELA imageWithColor: [ELA getColorAccent]];
    [btnNext setBackgroundImage:bg forState:UIControlStateNormal];
    
    UIColor *color = [UIColor colorWithRed: 153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    UIImage *bgOff = [ELA imageWithColor: color];
    [btnNext setBackgroundImage:bgOff forState:UIControlStateDisabled];
    
    [btnNext setTitle:nextLabel forState: UIControlStateNormal];
    [btnNext setFrame: CGRectMake(25, yOffset+150, scrn.size.width-50, 60)];
    
    [btnNext setClipsToBounds:YES];
    btnNext.layer.cornerRadius = 30;
    btnNext.layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.0f].CGColor;
    
    [btnNext addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: btnNext];
    
    if (currentSsid == nil) {
        [btnNext setEnabled: NO];
    }
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    BOOL isFirstResponder = (inputSsid.isFirstResponder || inputPass.isFirstResponder);
    BOOL isTouchView = (touch.view == inputSsid || touch.view == inputPass);
    
    if (isFirstResponder && !isTouchView) {
        [self.view endEditing: YES];
    }

    [super touchesBegan:touches withEvent:event];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == inputSsid) {
        if (![ELA isEmpty:textField.text]) {
            [btnNext setEnabled: YES];
        }
        else {
            [btnNext setEnabled: NO];
        }
    }
}

//when clicking the return button in the keybaord
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == inputSsid) {
        [inputSsid resignFirstResponder];
        [inputPass becomeFirstResponder];
    }
    else if (textField == inputPass) {
        [inputPass resignFirstResponder];
        [self goNext];
    }
    
    return YES;
}


- (void)goNext
{
    [self performSegueWithIdentifier:@"segueSync" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"segueSync"])
    {
        // Get reference to the destination view controller
        SetupSyncController *vc = [segue destinationViewController];
        vc.ssid = inputSsid.text;
        vc.pass = inputPass.text;
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
