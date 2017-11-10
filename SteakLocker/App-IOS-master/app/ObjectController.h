//
//  ProfileController.h
//  Steak Locker
//
//  Created by Jared Ashlock on 10/24/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#ifndef Steak_Locker_ObjectController_h
#define Steak_Locker_ObjectController_h

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "XLForm.h"
#import "MBProgressHUD.h"
#import "ItemsController.h"
#import "SLModels.h"

@interface ObjectController : XLFormViewController <XLFormDescriptorDelegate>

@property (nonatomic, strong) UIViewController *parent;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) MBProgressHUD *hudMsg;
@property (nonatomic, strong) XLFormSectionDescriptor*formSection;
@property (nonatomic, strong) XLFormRowDescriptor* rowCuts;

@property (nonatomic, strong) Object *selectedObject;

@property (nonatomic, strong) UserObject *userObject;
@property (nonatomic) BOOL isRemoving;
@property (nonatomic) BOOL isAdding;

- (IBAction)onCancel: (id)sender;
- (IBAction)onAdd: (id)sender;


- (void) reloadForm;
- (void)showErrorMsg:(NSString*)msg;
- (void)setCurrentUserObject: (UserObject*)userObject;
@end

#endif
