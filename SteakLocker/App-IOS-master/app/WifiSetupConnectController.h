//
//  SetupChooserController.h
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLForm.h"
#import "Reachability.h"


@interface WifiSetupConnectController : XLFormViewController <XLFormDescriptorDelegate>
@property (nonatomic, strong) UIButton *btnWifi;
@property (nonatomic, strong) UIButton *btnConnect;
@property (nonatomic, strong) UIButton *btnRead;
@property (nonatomic, strong) UIButton *btnSave;
@property (nonatomic, strong) UIButton *btnNormal;
@property (nonatomic, strong) UIButton *btnNext;
@property (nonatomic, strong) UIButton *btnCopy;

@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic) BOOL connectedToDeviceWifi;
@property (nonatomic, strong) XLFormSectionDescriptor *sectionConnection;
@property (nonatomic, strong) XLFormSectionDescriptor *sectionWifiCreds;
@property (nonatomic, strong) XLFormRowDescriptor * rowSsid;
@property (nonatomic, strong) XLFormRowDescriptor * rowPass;
@property (nonatomic, strong) XLFormRowDescriptor * rowBssid;
@property (nonatomic, strong) XLFormRowDescriptor * buttonBssid;
@property (nonatomic, strong) XLFormRowDescriptor * buttonRow;
@property (nonatomic, strong) XLFormRowDescriptor * rowConnection;

- (IBAction)onBack: (id)sender;
- (IBAction)onNext: (XLFormRowDescriptor *)sender;
- (IBAction)onTapCopy: (XLFormRowDescriptor *)sender;

@end

