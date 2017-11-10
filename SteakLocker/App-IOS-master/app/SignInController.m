
//
//  SignInController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

@import UIKit;
#import "SignInController.h"
#import "ELAAuthViewController.h"
#import "ELA.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"


@interface SignInController ()

@end

@implementation SignInController

const int VIEW_SIGN_UP = 0;
const int VIEW_SIGN_IN = 1;
int currentView = 0;
int isSlidUp = 0;

@synthesize btnSignUp;
@synthesize btnSignIn;
@synthesize btnAction;

@synthesize inputEmail;
@synthesize inputName;
@synthesize inputPass;

@synthesize btnCancel;


- (IBAction)onShowSignUp
{
    [self showSignUp];
}

- (void) showSignUp
{
    if (VIEW_SIGN_UP == currentView) {
        if (inputName.isFirstResponder || inputEmail.isFirstResponder || inputPass.isFirstResponder) {
            [self.view endEditing: YES];
            [self slideUp: FALSE];
        }
    }
    
    [btnSignUp setBackgroundColor: [UIColor whiteColor]];
    [btnSignIn setBackgroundColor: [ELA getColorBGLight]];
    
    if (currentView != VIEW_SIGN_UP) {
        [self hideTheInputs: FALSE duration: 0.25f];
        [self scrollTheInputs: FALSE];
        [btnAction setTitle:@"Sign Up" forState: UIControlStateNormal];
    }
    
    currentView = VIEW_SIGN_UP;
}

- (IBAction)onShowSignIn
{
    [self showSignIn];
}
- (void) showSignIn
{
    if (VIEW_SIGN_IN == currentView) {
        if (inputEmail.isFirstResponder || inputPass.isFirstResponder) {
            [self.view endEditing: YES];
            [self slideUp: FALSE];
        }
    }
    
    [btnSignUp setBackgroundColor: [ELA getColorBGLight]];
    [btnSignIn setBackgroundColor: [UIColor whiteColor]];
    
    if (currentView != VIEW_SIGN_IN) {
        
        if (inputName.isFirstResponder) {
            [inputName resignFirstResponder];
            [inputEmail becomeFirstResponder];
        }
        
        [self hideTheInputs: TRUE duration: 0.15f];
        [self scrollTheInputs: TRUE];
        [btnAction setTitle:@"Sign In" forState: UIControlStateNormal];
    }
    
    currentView = VIEW_SIGN_IN;
}

- (IBAction)onAction
{
    [self HandleUserAuth];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    int yOffset = 70;
    CGRect scrn = [ELA getScreen];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];

    btnSignUp = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSignUp setTitleColor: [ELA getColorText] forState: UIControlStateNormal];
    [btnSignUp setTitle:@"Sign Up" forState: UIControlStateNormal];
    [btnSignUp setFrame: CGRectMake(0, 0, scrn.size.width / 2, 60)];
    [btnSignUp addTarget:self action:@selector(onShowSignUp) forControlEvents:UIControlEventTouchUpInside];
    [btnSignUp setBackgroundColor: [UIColor whiteColor]];
    [self.view addSubview: btnSignUp];
    

    btnSignIn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSignIn setTitleColor: [ELA getColorText] forState: UIControlStateNormal];
    [btnSignIn setTitle:@"Sign In" forState: UIControlStateNormal];
    [btnSignIn setFrame: CGRectMake(scrn.size.width / 2, 0, scrn.size.width / 2, 60)];
    [btnSignIn addTarget:self action:@selector(onShowSignIn) forControlEvents:UIControlEventTouchUpInside];
    [btnSignIn setBackgroundColor: [ELA getColorBGLight]];
    [self.view addSubview: btnSignIn];
    
    
    
    btnAction = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAction setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [btnAction setBackgroundColor: [ELA getColorAccent]];
    [btnAction setTitle:@"Sign Up" forState: UIControlStateNormal];
    
    
    CGRect rect = self.view.frame;
    CGRect frame = CGRectMake(0, rect.size.height - 60 - 175, scrn.size.width, 60);
    [btnAction setFrame: frame];

    [btnAction addTarget:self action:@selector(onAction) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview: btnAction];

    
    
    inputName = [[UITextField alloc] initWithFrame: CGRectMake( 50, yOffset+0, 260, 50 )];
    inputName.placeholder = @"Your Full Name";
    inputName.autocapitalizationType = UITextAutocapitalizationTypeWords;
    inputName.delegate = self;
    [inputName setReturnKeyType:UIReturnKeyNext];
    [self.view addSubview: inputName];
    _iconName = [ELA addImage:@"IconName" X:0 Y:yOffset+0 W:50 H:50];
    [self.view addSubview: _iconName];
    _lineName = [ELA addImage:@"InputLine" X:0 Y:yOffset+50 W:scrn.size.width H:1];
    [self.view addSubview: _lineName];
    
    
    inputEmail = [[UITextField alloc] initWithFrame: CGRectMake( 50, yOffset+50, 260, 50 )];
    inputEmail.placeholder = @"Email Address";
    [inputEmail setKeyboardType:UIKeyboardTypeEmailAddress];
    inputEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
    inputEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    inputEmail.delegate = self;
    [inputEmail setReturnKeyType:UIReturnKeyNext];
    [self.view addSubview: inputEmail];
    _iconEmail = [ELA addImage:@"IconEmail" X:0 Y:yOffset+50 W:50 H:50];
    [self.view addSubview: _iconEmail];
    _lineEmail = [ELA addImage:@"InputLine" X:0 Y:yOffset+100 W:scrn.size.width H:1];
    [self.view addSubview: _lineEmail];
    

    inputPass = [[UITextField alloc] initWithFrame: CGRectMake( 50, yOffset+100, 260, 50 )];
    inputPass.placeholder = @"Password";
    inputPass.autocapitalizationType = UITextAutocapitalizationTypeNone;
    inputPass.secureTextEntry = true;
    inputPass.delegate = self;
    
    [inputName setReturnKeyType:UIReturnKeyGo];
    [self.view addSubview: inputPass];
    _iconPass = [ELA addImage:@"IconPass" X:0 Y:yOffset+100 W:50 H:50];
    [self.view addSubview: _iconPass];
    _linePass = [ELA addImage:@"InputLine" X:0 Y:yOffset+150 W:scrn.size.width H:1];
    [self.view addSubview: _linePass];
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    BOOL isFirstResponder = (inputName.isFirstResponder || inputEmail.isFirstResponder || inputPass.isFirstResponder);
    BOOL isTouchView = (touch.view == inputName || touch.view == inputEmail || touch.view == inputPass);
    
    if (isFirstResponder && !isTouchView) {
        [self.view endEditing: YES];
        [self slideUp: FALSE];
    }

    [super touchesBegan:touches withEvent:event];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self slideUp: TRUE];
}

//when clicking the return button in the keybaord
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == inputName) {
        [inputName resignFirstResponder];
        [inputEmail becomeFirstResponder];
    }
    else if (textField == inputEmail) {
        [inputEmail resignFirstResponder];
        [inputPass becomeFirstResponder];
    }
    else if (textField == inputPass) {
        [inputName resignFirstResponder];
        [self HandleUserAuth];
    }
    
    return YES;
}

- (ELAAuthViewController *) getParent
{
    return (ELAAuthViewController*) self.parentViewController;
}

- (void) slideUp: (BOOL)slideUp
{
    if ((slideUp && VIEW_SIGN_UP == isSlidUp) || (!slideUp && VIEW_SIGN_IN == isSlidUp))
    {
        CGRect frame = [self getActionButtonFrame: slideUp];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        [btnAction setFrame: frame];

        [UIView commitAnimations];
        
        ELAAuthViewController *parent = [self getParent];
        [parent slideScreen: slideUp];

        isSlidUp = (slideUp) ? 1 : 0;
    }
}

- (CGRect)getActionButtonFrame: (BOOL)forSlideUp
{
    CGRect rect = self.view.frame;
    CGRect frame = btnAction.frame;
    frame.size.height = 60;
    frame.size.width = rect.size.width;
    
    if (forSlideUp) {
        frame.origin.y = (currentView == VIEW_SIGN_IN) ? 171 : 221;
    }
    else {
        frame.origin.y = rect.size.height - frame.size.height - 175 + 22;
    }

    return frame;
}

- (void)scrollTheInputs: (BOOL)move
{
    // Input positions:  non-scrolled  /  Scrolled
    // Name:		70
    // Email:		130	/ 70
    // Pass:		180	/ 130
    // Button:		250 / 200
    
    // scroll the view up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.25f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    CGRect frame;
    
    // Email
    ////////////////
    // INPUT
    frame = inputEmail.frame;
    frame.origin.y = (move) ? 70 : 120;
    inputEmail.frame = frame;
    // ICON
    frame = _iconEmail.frame;
    frame.origin.y = (move) ? 70 : 120;
    _iconEmail.frame = frame;
    // LINE
    frame = _lineEmail.frame;
    frame.origin.y = (move) ? 120 : 170;
    _lineEmail.frame = frame;
    
    
    // Pass
    ////////////////
    // INPUT
    frame = inputPass.frame;
    frame.origin.y = (move) ? 120 : 170;
    inputPass.frame = frame;
    // ICON
    frame = _iconPass.frame;
    frame.origin.y = (move) ? 120 : 170;
    _iconPass.frame = frame;
    // LINE
    frame = _linePass.frame;
    frame.origin.y = (move) ? 170 : 220;
    _linePass.frame = frame;
    
    
    if (isSlidUp > 0) {
        // Button
        frame = btnAction.frame;
        frame.origin.y = (move) ? 171 : 221;
        btnAction.frame = frame;
    }
    
    [UIView commitAnimations];
    
}


- (void)hideTheInputs: (BOOL)hide duration: (float) dur
{
    // scroll the view up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: dur];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    if (hide) {
        inputName.alpha = 0.0f;
        _lineName.alpha = 0.0f;
        _iconName.alpha = 0.0f;
    } else {
        inputName.alpha = 1.0f;
        _lineName.alpha = 1.0f;
        _iconName.alpha = 1.0f;
    }
    
    [UIView commitAnimations];
}

- (void) HandleUserAuth {
    PFUser *user = nil;
    
    NSString *email = [inputEmail.text lowercaseString];
    

    if (currentView == VIEW_SIGN_UP) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Signing Up...";
        
        
        user = [PFUser user];
        user.username = email;
        user.email = email;
        user.password = inputPass.text;
        user[@"name"] = inputName.text;
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (!error) {
                // Hooray! Let them use the app now.
                [self goNext: true];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"%@", errorString);
            }
        }];
    } else {

        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Signing In...";
        
        [PFUser logInWithUsernameInBackground:email password:inputPass.text block:^(PFUser *user, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (user) {
                [self goNext: false];
                // Do stuff after successful login.
            } else {
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"%@", errorString);
            }
        }];
    }
    
}

- (void)goNext: (BOOL)newUser
{
    [ELA saveInstallationUser];
    [ELA onSuccessfulLogin: newUser controller:self];
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
