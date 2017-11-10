
//
//  SignInController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

@import UIKit;
#import "WifiSetupStatusController.h"
#import "ELA.h"
#import "ELADevice.h"
#import "FloatLabeledTextFieldCell.h"
#import "XLFormConnectionStatus.h"


@interface WifiSetupStatusController ()

@end

@implementation WifiSetupStatusController

@synthesize btnWifi;
@synthesize btnConnect;
@synthesize btnRead;
@synthesize btnSave;
@synthesize btnNormal;
@synthesize btnNext;




- (IBAction)onBack: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onNext: (XLFormRowDescriptor *)sender
{
    [self deselectFormRow:sender];
 
    [ELA loadStoryboard:self storyboard:@"Dashboard"];
    
}

- (IBAction)onReadSettings
{
    ELADevice *elaDevice = [ELA getElaDevice];
    
    [elaDevice readSettings];
}


- (IBAction)onSaveSettings
{
    ELADevice *elaDevice = [ELA getElaDevice];
    
    [elaDevice saveSettings];
}

- (IBAction)onApiConnect
{
    ELADevice *elaDevice = [ELA getElaDevice];
    [elaDevice apiConnect];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    ELADevice *elaDevice = [ELA getElaDevice];
    [elaDevice saveSettings];
}

- (void)viewDidLoad
{
    // Do any additional setup after loading the view, typically from a nib.
    CGRect scrn = [[UIScreen mainScreen] bounds];
     
    [self.view setBackgroundColor: [ELA getColorBGLight]];
    
    
    self.status = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, scrn.size.width-30, 200)];
    [self.status setFont:[ELA getFont:17]];
    [self.status setNumberOfLines:0];
    [self.status setTextAlignment:NSTextAlignmentCenter];
    [self.status setText:@"Connecting locker to your account..."];
    [self.view addSubview:self.status];
    
    [ELA on:@"settingsSaved" notify:^{
        NSLog(@"ELA on[settingsSaved] before sleep");
        sleep(1);
        NSLog(@"ELA on[settingsSaved] after sleep");
        [self onApiConnect];
    }];
    
    [ELA on:@"apiConnected" notify:^{
        NSLog(@"ELA on[apiConnected] before sleep");
        sleep(1);
        NSLog(@"ELA on[apiConnected] after sleep");
        
        ELADevice *elaDevice = [ELA getElaDevice];
        [elaDevice initStatusCheck];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.status setText:@"Waiting for your locker to come online..."];
        });
    }];
    [ELA on:@"deviceConnected" notify:^{
        ELADevice *elaDevice = [ELA getElaDevice];
        [ELA reloadUserDevices:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [elaDevice cancelStatusCheck];
            PFObject *device = [ELA getUserDeviceByImpeeId: elaDevice.uniqueId];
            if (device != nil) {
                [ELA setUserDevice:device];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ELA loadStoryboard:self storyboard:@"Dashboard"];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.status setText:@"Oops, something went wrong."];
                });
            }
            
        }];
    }];
    
    [ELA on:@"deviceConnectionTimeout" notify:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.status setText:@"Oops, something went wrong, we ran out of time."];
        });
    }];
    
}
@end
