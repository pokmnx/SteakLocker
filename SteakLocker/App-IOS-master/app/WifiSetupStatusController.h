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


@interface WifiSetupStatusController : XLFormViewController <XLFormDescriptorDelegate>
@property (nonatomic, strong) UIButton *btnWifi;
@property (nonatomic, strong) UIButton *btnConnect;
@property (nonatomic, strong) UIButton *btnRead;
@property (nonatomic, strong) UIButton *btnSave;
@property (nonatomic, strong) UIButton *btnNormal;
@property (nonatomic, strong) UIButton *btnNext;

@property (nonatomic, strong) UILabel *status;

- (IBAction)onBack: (id)sender;
- (IBAction)onNext: (XLFormRowDescriptor *)sender;

@end

