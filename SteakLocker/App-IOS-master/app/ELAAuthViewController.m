//
//  ViewController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import "ELAAuthViewController.h"
#import "SignInController.h"
#import "ELA.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ELAAuthViewController ()

@end

@implementation ELAAuthViewController
@synthesize bg;
@synthesize headerLogo;
@synthesize signInView;
@synthesize btnFB;
@synthesize btnEmail;
@synthesize btnLogin;

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self.view setBackgroundColor:[UIColor grayColor]]; 
    UIImage *bgImage = [UIImage imageNamed:@"LoginBackground"];
    bg = [[UIImageView alloc] initWithFrame:[ELA getScreen]];
    [bg setImage: bgImage];
    [bg setContentMode: UIViewContentModeScaleAspectFill];
    [self.view addSubview:bg];
    
    headerLogo = [[UIImageView alloc] initWithFrame:[self getLogoFrame]];
    [headerLogo setImage:[UIImage imageNamed:@"LoginHeaderLogo"]];
    [headerLogo setContentMode: UIViewContentModeScaleAspectFit];
    [self.view addSubview:headerLogo];
    
    signInView = [[SignInController alloc] init];
    [self addChildViewController: signInView];
    [signInView didMoveToParentViewController:self];
    [self.view addSubview: signInView.view];
    [signInView.view setHidden:YES];
    
    
    CGRect scrn = [ELA getScreen];
    float ratio = 903.0f / 172.0f;
    float margin = scrn.size.width * 0.1f;
    float width = scrn.size.width - (2*margin);
    float height = width / ratio;
    
    btnFB = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnFB setImage:[UIImage imageNamed:@"LoginFacebook"] forState:UIControlStateNormal];
    [btnFB setImage:[UIImage imageNamed:@"LoginFacebook"] forState:UIControlStateSelected];
    [btnFB setFrame: CGRectMake(margin, scrn.size.height-(height*4.5), width, height)];
    [btnFB addTarget:self action:@selector(onActionFacebook) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: btnFB];
    
    
    btnEmail = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnEmail setImage:[UIImage imageNamed:@"LoginEmail"] forState:UIControlStateNormal];
    [btnEmail setImage:[UIImage imageNamed:@"LoginEmail"] forState:UIControlStateSelected];
    [btnEmail setFrame: CGRectMake(margin, scrn.size.height-(height*3.25), width, height)];
    [btnEmail addTarget:self action:@selector(onActionEmailSignup) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: btnEmail];
    
    
    UITapGestureRecognizer *tap = nil;
    btnLogin = [[UILabel alloc] initWithFrame:CGRectMake(margin, scrn.size.height-(height*2), width, height)];
    [btnLogin setText:@"Already have an account? Log In"];
    [btnLogin setFont:[UIFont systemFontOfSize:13 weight:UIFontWeightBold]];
    [btnLogin setTextColor:[UIColor whiteColor]];
    [btnLogin setUserInteractionEnabled:YES];
    [btnLogin setTextAlignment:NSTextAlignmentCenter];
    
    NSMutableAttributedString *login = [[NSMutableAttributedString alloc] initWithString:@"Already have an account? Log In"];
    [login addAttribute:NSUnderlineStyleAttributeName
                  value:[NSNumber numberWithInt:1]
                  range:(NSRange){25,6}];
    btnLogin.attributedText = [login copy];    
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onActionEmailLogin)];
    tap.numberOfTapsRequired = 1;
    [btnLogin addGestureRecognizer:tap];
    
    [self.view addSubview: btnLogin];

    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBackground)];
    tap.numberOfTapsRequired = 1;
    [bg setUserInteractionEnabled:YES];
    [bg addGestureRecognizer:tap];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [self adjustSubviewSizes];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (int)getLoginHeaderHeight
{
    return 175;
}
- (CGRect)getLogoFrame
{
    CGRect rect;
    CGRect scrn = [ELA getScreen];
    rect.size.width = 218;
    rect.size.height = [self getLoginHeaderHeight];
    rect.origin.x = (scrn.size.width - rect.size.width) / 2;
    return rect;
}

- (CGRect)getSignInFrame: (bool)slideUp
{
    CGRect rect = [ELA getScreen];
    int hh = [self getLoginHeaderHeight];
    int sh = [ELA getStatusBarHeight];
    rect.origin.y = slideUp ? sh : hh;
    rect.size.height -= slideUp ? sh : hh;
    return rect;
}

- (void)adjustSubviewSizes
{
    CGRect scrn = [ELA getScreen];
    [bg setFrame: scrn];
    [headerLogo setFrame: [self getLogoFrame]];
    [signInView.view setFrame: [self getSignInFrame:NO]];
}


- (void)slideScreen: (BOOL)slideUp {

    // scroll the view up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

    [signInView.view setFrame: [self getSignInFrame:slideUp]];
    
    [UIView commitAnimations];
}

- (void)showButtons: (bool) show
{
    if (show) {
        [btnFB setHidden:NO];
        [btnEmail setHidden:NO];
        [btnLogin setHidden:NO];
    }
    else {
        [btnFB setHidden: YES];
        [btnEmail setHidden:YES];
        [btnLogin setHidden:YES];
    }
}

- (void)slideInForm: (bool)slideIn
{
    CGRect frame = (slideIn) ? [self getSignInFrame:NO] : signInView.view.frame;
    
    if (slideIn) {
        frame.origin.y += frame.size.height;
        [signInView.view setFrame: frame];
        [signInView.view setHidden: NO];
        [self.view bringSubviewToFront: signInView.view];
//        [self showButtons: NO];
    }

    // scroll the view up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    if (slideIn) {
        frame.origin.y -= frame.size.height;
    }
    else {
        frame.origin.y = [ELA getScreen].size.height;
    }
    
    if (!slideIn) {
//        [self showButtons: YES];
    }
    [signInView.view setFrame: frame];
    
    [UIView commitAnimations];
}


-(void)onActionFacebook
{
    [self doFacebookLogin];
}
-(void) onActionEmailSignup
{
    [signInView showSignUp];
    [self slideInForm: YES];
}
- (void)onActionEmailLogin
{
    [signInView showSignIn];
    [self slideInForm: YES];
}

- (void) onTapBackground
{
    [self slideInForm: NO];
}


- (void)doFacebookLogin
{
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"email"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                
            } else {
                
            }
            
            [ELA updateUserFromFacebook:^(BOOL success) {
                [ELA onSuccessfulLogin: user.isNew controller:self];
            }];
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

@end
