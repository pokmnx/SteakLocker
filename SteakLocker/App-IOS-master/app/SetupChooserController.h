//
//  SetupChooserController.h
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLForm.h"


@interface SetupChooserController : XLFormViewController <XLFormDescriptorDelegate>

@property (nonatomic, strong) XLFormRowDescriptor  *rowSeries;
@property (nonatomic, strong) XLFormRowDescriptor  *rowModel;

@property (nonatomic, strong) UIImageView *imageProduct;

- (IBAction)onBack: (id)sender;
- (IBAction)onNext: (XLFormRowDescriptor *)sender;

@end

