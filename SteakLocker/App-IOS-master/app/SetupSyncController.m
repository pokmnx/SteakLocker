
//
//  SignInController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//
// Convenient macros that log the name, value and file location of an object or the method in which the macro appears.
#define LOG_OBJECT(object)  (NSLog(@"" #object @" %@ %@:%d", [object description], [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__));
#define LOG_METHOD          (NSLog(@"%@ %@:%d\n%@", NSStringFromSelector(_cmd), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, self))

// Useful, protective assertion macros
#define ASSERT_IS_CLASS(x, class)    NSAssert5([x isKindOfClass:class], @"\n\n    ****  Unexpected Assertion  **** \nReason: Expected class:%@ but got:%@\nAssertion in file:%s at line %i in Method %@", NSStringFromClass(class), x, __FILE__, __LINE__, NSStringFromSelector(_cmd))
#define SUBCLASSES_MUST_OVERRIDE     NSAssert2(FALSE, @"%@ Subclasses MUST override this method:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#define SHOULD_NEVER_GET_HERE        NSAssert4(FALSE, @"\n\n    ****  Should Never Get Here  **** \nAssertion in file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)




@import UIKit;
#import "SetupSyncController.h"
#import "ELA.h"
#import "MBProgressHUD.h"

@interface SetupSyncController ()

@end

@implementation SetupSyncController
MBProgressHUD *hud;

@synthesize labelTitle;
@synthesize titleLabel;
@synthesize nextLabel;
@synthesize desc;
@synthesize imagePower;
@synthesize imageBlink;
@synthesize btnSync;
@synthesize btnNext;
@synthesize ssid;
@synthesize pass;


- (void)viewDidLoad {
    titleLabel = @"Power Up";
    nextLabel = @"Sync";
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // Do any additional setup after loading the view, typically from a nib.
    CGRect scrn = [[UIScreen mainScreen] bounds];
    
    [self.view setBackgroundColor: [ELA getColorBGLight]];
    
    CGRect rect = CGRectMake(15, 25, scrn.size.width-30, 20);
    labelTitle = [[UILabel alloc] initWithFrame: rect];
    
    [labelTitle setFont: [UIFont systemFontOfSize: 17]];
    [labelTitle setTextAlignment:NSTextAlignmentCenter];
    labelTitle.text = titleLabel;
    [self.view addSubview: labelTitle];
    
    desc = [[UILabel alloc] initWithFrame: CGRectMake(10, rect.origin.y+rect.size.height + 0, scrn.size.width-20, 20)];
    [desc setFont: [UIFont systemFontOfSize: 13]];
    desc.text = @"Connect your atomizer to power source.";
    desc.textAlignment = NSTextAlignmentCenter;
    desc.numberOfLines = 5;
    [self.view addSubview: desc];
    
    
    float margin = scrn.size.width * 0.4f / 2.0f;
    float width  = scrn.size.width - margin - margin;
    float height = width / 1.5f;
    CGRect rectImage = CGRectMake(margin, desc.frame.origin.y+desc.frame.size.height+10, scrn.size.width-(margin*2), height);
    imagePower = [ELA addImage:@"SyncPowerUp" frame: rectImage];
    [self.view addSubview:imagePower];
    
    
    
    rect = CGRectMake(15, rectImage.origin.y+rectImage.size.height+25, scrn.size.width-30, 20);
    _title2 = [[UILabel alloc] initWithFrame: rect];
    
    [_title2 setFont: [UIFont systemFontOfSize: 17]];
    [_title2 setTextAlignment:NSTextAlignmentCenter];
    _title2.text = @"Sync";
    [self.view addSubview: _title2];
    
    _desc2 = [[UILabel alloc] initWithFrame: CGRectMake(10, rect.origin.y+rect.size.height + 0, scrn.size.width-20, 40)];
    [_desc2 setFont: [UIFont systemFontOfSize: 13]];
    _desc2.text = @"Place your atomizer on the screen of your phone and press the sync button below.";
    _desc2.textAlignment = NSTextAlignmentCenter;
    _desc2.numberOfLines = 2;
    [self.view addSubview: _desc2];
    
    
    margin = scrn.size.width * 0.5f / 2.0f;
    width  = scrn.size.width - margin - margin;
    height = width / 1.377f;
    rectImage = CGRectMake(margin, _desc2.frame.origin.y+_desc2.frame.size.height+10, scrn.size.width-(margin*2), height);
    imageBlink = [ELA addImage:@"SyncBlinkUp" frame: rectImage];
    [self.view addSubview:imageBlink];

    
    /*
    
    btnTroubleshoot = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnTroubleshoot setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [btnTroubleshoot setBackgroundColor: [ELA getColorAccent]];
    [btnTroubleshoot setTitle:@"Troubleshoot" forState: UIControlStateNormal];
    [btnTroubleshoot setFrame: CGRectMake(0, 85, scrn.size.width, 60)];
    [btnTroubleshoot addTarget:self action:@selector(onTroubleshoot) forControlEvents:UIControlEventTouchUpInside];
    [btnTroubleshoot setHidden:YES];
    [self.view addSubview: btnTroubleshoot];
     */
    
    [self.view setBackgroundColor: [ELA getColorBGLight]];
    
    btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    UIImage *bg = [ELA imageWithColor: [ELA getColorAccent]];
    [btnNext setBackgroundImage:bg forState:UIControlStateNormal];
    
    UIColor *color = [UIColor colorWithRed: 153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    UIImage *bgOff = [ELA imageWithColor: color];
    [btnNext setBackgroundImage:bgOff forState:UIControlStateDisabled];
    
    [btnNext setTitle:nextLabel forState: UIControlStateNormal];
    
    CGRect rectNext = CGRectMake(25, rectImage.origin.y+rectImage.size.height+40, scrn.size.width-50, 60);
    [btnNext setFrame: rectNext];
    [btnNext addTarget:self action:@selector(flashSSID) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: btnNext];

    [btnNext setClipsToBounds:YES];
    btnNext.layer.cornerRadius = 30;
    btnNext.layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.0f].CGColor;

    [self.view addSubview: btnNext];
    
    UIScrollView * scrollView = (UIScrollView *)self.view;
    CGSize size  = CGSizeMake(scrn.size.width, rectNext.origin.y+rectNext.size.height+20);
    [scrollView setContentSize:size];
}

- (void)viewWillAppear:(BOOL)animated
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    [backButton setTintColor:[ELA getColorAccent]];

    self.navigationItem.leftBarButtonItem = backButton;

    
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    //Remove listening for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction)onNext
{
    [self goNext];
    
}


- (void)goBack
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)goNext
{
    [self performSegueWithIdentifier:@"segueComplete" sender:self];
    
    [ELA reloadUserDevices:^(NSArray * objects, NSError * error) {
        [ELA loadStoryboard:self storyboard:@"Dashboard" animated:YES];
        
    }];
}

- (void)onTroubleshoot
{
    [ELA loadConfig:^(BOOL success, PFConfig* config){
        if (![ELA isEmpty:config[@"troubleshootUrl"]]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:config[@"troubleshootUrl"]]];
        }
    }];    
}

- (void)hideKeyboard;
{
/*
    [self.ssidField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.wpsField resignFirstResponder];
*/
}



- (void) flashError
{
    [btnNext setTitle:@"Sync" forState: UIControlStateNormal];
    [btnNext setEnabled:YES];
}

//*****************************************************************************
#pragma mark -
#pragma mark ** IBActions **



/*!
 *  @brief Add Addressing and Proxy if enabled
 *
 *  @param networkConfig Network Configuration to alter
 *
 *  @return False on error, True otherwise
 */

- (BOOL)addAddressingAndProxyToNetworkConfig:(BUNetworkConfig *)networkConfig {
/*
    // Configure static addressing if enabled
    if (self.useStaticSwitch.isOn) {
        BUStaticAddressing *staticAddressing = [self staticAddressingFromUI];
        if (staticAddressing != nil) {
            networkConfig.addressing = staticAddressing;
        } else {
            return false;
        }
    }
    
    // Configure proxy if enabled
    if (self.useProxySwitch.isOn) {
        BUNetworkProxy *proxy = [self proxyFromUI];
        if (proxy != nil) {
            networkConfig.proxy = proxy;
        } else {
            return false;
        }
    }
*/
    return true;
}


- (void)showErrorMessage: (NSString*)message
{
    
    
    NSString *msg = [NSString stringWithFormat:@"%@\n\nIf you are having issues syncing your device, please try again or submit a support ticket below.", message];
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Error"
                                 message: msg
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction* faqs = [UIAlertAction
                               actionWithTitle:@"FAQs"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self onTroubleshoot];
                               }];
    UIAlertAction* support = [UIAlertAction
                               actionWithTitle:@"Technical Support"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [ELA supportEmail];
                               }];
    
    UIAlertAction* tryAgain = [UIAlertAction
                                actionWithTitle:@"Okay"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    
    
    [alert addAction:faqs];
    [alert addAction:support];
    [alert addAction:tryAgain];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)flashSSID
{
    [self hideKeyboard];
    
    [btnNext setTitle:@"Processing..." forState: UIControlStateDisabled];
    [btnNext setEnabled:NO];
 

    //If using password:
    BUWifiConfig *wifiConfig = [[BUWifiConfig alloc]initWithSSID:ssid password:pass];
    
    //If using saved ssid
    // BUWifiConfig * wifiConfig = [[BUWifiConfig alloc] initWithExistingSSID:self.ssidField.text];
    
    BOOL configureSuccess = [self addAddressingAndProxyToNetworkConfig:wifiConfig];
    if (!configureSuccess) {
        return;
    }
    
    BUConfigId *configId = [[BUConfigId alloc]initWithApiKey:[ELA getAPIKey] completionHandler: ^(BUConfigId *configId, NSError *error) {
        if (error) {
            LOG_METHOD;
            LOG_OBJECT(error);
        } else {
            BUFlashController *flashController = [[BUFlashController alloc]init];
            [flashController presentFlashWithNetworkConfig:wifiConfig configId:configId animated:YES resignActive: ^(BOOL willRespond, BUDevicePoller *devicePoller, NSError *error) {
                if (error) {
                    LOG_METHOD;
                    LOG_OBJECT(error);
                    [self flashError];
                }
                else if (!willRespond) {
                    LOG_METHOD;
                    LOG_OBJECT(@"Flash was of non-wifi connection type");
                    [self flashError];
                }
                else{
                    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeIndeterminate;
                    hud.labelText = @"Syncing...";
                    
                    [self.navigationItem.leftBarButtonItem setEnabled:NO];
                    
                    [devicePoller startPollingWithCompletionHandler: ^(BUDeviceInfo *deviceInfo, BOOL timedOut, NSError *error) {
                        [MBProgressHUD hideHUDForView:self.view animated:NO];
                        [self.navigationItem.leftBarButtonItem setEnabled:YES];
                        if (error) {
                            [self showErrorMessage: [error localizedDescription]];
                        }
                        else if (timedOut) {
                            [self flashError];
                            [self showErrorMessage:@"The atomizer did not respond"];
                        }
                        else{
                            [self blinkUpSuccess:deviceInfo];
                        }
                    }];
                }
            }];
        }
    }];
}



- (IBAction)flashClearConfig
{
    [self hideKeyboard];
    
    /*
    BlinkUpController *blinkUpController = [[BlinkUpController alloc] init];
    
    NSError *err = [blinkUpController presentClearDeviceFlashWithDelegate:self animated:NO];
    
    if (err != nil)
    {
        LOG_METHOD;
        LOG_OBJECT(err);
    }
     */
}

#pragma mark -
#pragma mark ** Unused Usefull methods **


//This method generates an array containing ssids as strings.
// If a current network is available it will be listed first (and will not be duplicated if saved)
// An "Other Network" option is added for manual entry
-(NSArray *) ssidArrayForTableView {
    NSMutableArray *ssids = [NSMutableArray arrayWithCapacity:6];
    
    
    NSArray *wifiConfigs = [BUNetworkManager allWifiConfigs];
    
    for (BUWifiConfig *wifiConfig in wifiConfigs) {
        [ssids addObject:wifiConfig.ssid];
    }
    
    //Add a "other" network for custom entry
    [ssids addObject:@"Other Network"];
    
    return [ssids copy];
}


//*****************************************************************************
#pragma mark -
#pragma mark ** BlinkUpDelegate **

/*
- (void)blinkUp:(BlinkUpController *)blinkUpController flashCompleted:(BOOL)flashDidComplete;
{

    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Syncing...";

    //[icon setHidden:YES];
    //[btnTroubleshoot setHidden:NO];
    [btnNext setTitle:@"Sync" forState: UIControlStateNormal];
}
*/
- (void)blinkUpSuccess:(BUDeviceInfo *)deviceInfo
{
    //The planId property can also be saved if needed
    // self.blinkedUpWithPlanId = blinkUpController.planId;
    if (deviceInfo != nil) {
    
        NSString *url = [deviceInfo.agentURL absoluteString];;

        [ELA saveDevice:deviceInfo.deviceId planId:deviceInfo.planId agentUrl:url callback:^{
            
            [self goNext];    
        }];
        
        
    }
}


@end
