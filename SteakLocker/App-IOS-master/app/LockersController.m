//
//  SettingsController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import "LockersController.h"
#import <Parse/Parse.h>
#import "ELA.h"

#import "SettingsController.h"

@interface LockersController ()

@end

@implementation LockersController

@synthesize hud;
@synthesize hudMsg;
@synthesize formDevices;
@synthesize sectionDevices;


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor  =[ELA getColorBGLight];
    self.view.backgroundColor = [ELA getColorBGLight];

    self.theMenu = [ELA initDropMenuAndAdd:self];
}

-(void)initializeForm
{
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;

    formDevices = [XLFormDescriptor formDescriptor];
    sectionDevices = [XLFormSectionDescriptor formSectionWithTitle: @"Lockers"];
    [formDevices addFormSection:sectionDevices];
    
    NSArray* devices = [ELA getUserDevices];
    for (PFObject *device in devices) {
        [self addDevice:device];
    }

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"newLocker" rowType:XLFormRowDescriptorTypeButton title: @"Add Locker"];
    
    row.height = 70.0f;

    [row.cellConfig setObject:[ELA getColorAccent] forKey:@"backgroundColor"];
    [row.cellConfig setObject:[UIColor whiteColor] forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:[ELA getFont:20.0f] forKey:@"textLabel.font"];

    // Do this to hack the XLForm button to be rounded, since is actually a tableviewcell masquerading as a button
    [row.cellConfig setObject:@(35.0f) forKey:@"layer.cornerRadius"];
    [row.cellConfig setObject:@(YES) forKey:@"clipsToBounds"];
    [row.cellConfig setObject:@(15.0f) forKey:@"layer.borderWidth"];
    [row.cellConfig setObject:[ELA getColorBGLight].CGColor forKey:@"layer.borderColor"];
    
    
    

    row.action.formBlock = ^(XLFormRowDescriptor * sender){
        [ELA startAddNewDevice:self];
    };
    
    
    [sectionDevices addFormRow:row];
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle: @"Units"];
    [formDevices addFormSection:section];

    // Selector Push
    self.tempC = @"  ° C  ";
    self.tempF = @"  ° F  ";
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"unitType" rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Temperature Display"];
    row.selectorOptions = @[self.tempC, self.tempF];
    
    BOOL isF = [ELA isUseFahrenheit];
    row.value = isF ? self.tempF : self.tempC;
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"weightType" rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Weight Display"];
    XLFormOptionsObject *weightUs = [XLFormOptionsObject formOptionsObjectWithValue:@"us" displayText:@"lbs/oz"];
    XLFormOptionsObject *weightMet = [XLFormOptionsObject formOptionsObjectWithValue:@"metric" displayText:@"kg/g"];
    row.selectorOptions = @[weightUs, weightMet];;
    row.value = [ELA isMetric] ? weightMet : weightUs;
    [section addFormRow:row];
    
    
    /*
    section = [XLFormSectionDescriptor formSectionWithTitle: @"Alerts and Notifications"];
    [formDevices addFormSection:section];
    // Switch
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"alertsEnabled" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Alerts"];

    BOOL alerts = [ELA isAlertsEnabled];
    row.value = [NSNumber numberWithBool:alerts];
    [section addFormRow:row];
     */
    
    
    // PROIFILE
    PFUser *user = [PFUser currentUser];
    
    section = [XLFormSectionDescriptor formSectionWithTitle: @"Profile"];
    [formDevices addFormSection:section];
    
    // Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"inputName" rowType:XLFormRowDescriptorTypeText title:@"Name"];
    row.required = YES;
    [row.cellConfig setObject:[ELA getFont:14.0f] forKey:@"textLabel.font"];
    row.value = user[@"name"];
    [section addFormRow:row];
    
    // Email
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"inputEmail" rowType:XLFormRowDescriptorTypeEmail title:@"Email"];
    [row.cellConfig setObject:[ELA getFont:14.0f] forKey:@"textLabel.font"];
    row.value = user[@"email"];
    // validate the email
    [row addValidator:[XLFormValidator emailValidator]];
    [section addFormRow:row];
    
    // Password
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"inputPass" rowType:XLFormRowDescriptorTypePassword title:@"Password"];
    [row.cellConfig setObject:[ELA getFont:14.0f] forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    // Button
    XLFormRowDescriptor * buttonRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"saveProfile" rowType:XLFormRowDescriptorTypeButton title:@"Save Profile"];
    [buttonRow.cellConfig setObject:[ELA getColorAccent] forKey:@"textLabel.textColor"];
    [buttonRow.cellConfig setObject:[ELA getFont:20.0f] forKey:@"textLabel.font"];
    buttonRow.action.formSelector = @selector(didTouchButton:);
    [section addFormRow:buttonRow];
    
    
    
    
    self.form = formDevices;
    self.form.delegate = self;
    
}


-(void)didTouchButton:(XLFormRowDescriptor *)sender
{
    
    if ([sender.tag isEqualToString:@"saveProfile"]){
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.dimBackground = YES;
        hud.labelText = @"Saving Profile...";
        
        PFUser *user = [PFUser currentUser];
        
        NSDictionary * values = [self formValues];
        user[@"name"] = values[@"inputName"];
        user.email = values[@"inputEmail"];
        user.username = user.email;
        
        
        NSString *newPass = values[@"inputPass"];
        if ([newPass isKindOfClass:[NSString class]] && [newPass length] > 0) {
            user.password = newPass;
        }
        
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            hudMsg = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hudMsg.mode = MBProgressHUDModeCustomView;
            [hudMsg hide:YES afterDelay:3];
            
            if (error) {
                hudMsg.labelText = @"An error occured";
            }
            else {
                hudMsg.labelText = @"Profile Saved";
            }
        }];
        
    }
    [self deselectFormRow:sender];
}

- (void)addDevice: (PFObject *)device
{
    XLFormRowDescriptor * row;
    
    NSString *nickname = [device objectForKey:@"nickname"];

    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:device.objectId rowType:XLFormRowDescriptorTypeButton title: nickname];
    
    if ([ELA isDeviceActive:device]) {
        [row.cellConfig setObject:[ELA getColorAccent] forKey:@"textLabel.textColor"];
    }
    row.action.formSegueIdentifier = @"showLockerSettings";
    
    [sectionDevices addFormRow:row];

}

- (void)updateDevices
{
    NSMutableArray* rows = sectionDevices.formRows;
    for (XLFormRowDescriptor* row in rows) {
        PFObject *device = [ELA getUserDeviceById:row.tag];
        BOOL active = [ELA isDeviceActive:device];
        UIColor *color = (active) ? [ELA getColorAccent] : [UIColor blackColor];
        
        [row.cellConfig setObject:color forKey:@"textLabel.textColor"];

        [self reloadFormRow:row];
    }
    
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self.view setBackgroundColor:[ELA getColorBGLight]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onMenu: (id)sender
{
    self.theMenu.activeItemName = @"Settings";
    if (self.theMenu.showing) {
        [self.theMenu hideMenu];
        [self.theMenu setAlpha:0.0f];
        [self.view sendSubviewToBack:self.theMenu];
    }
    else {
        [self.view bringSubviewToFront:self.theMenu];
        [self.theMenu setAlpha:1.0f];
        [self.theMenu showMenu];
    }
}

- (IBAction)onLogout:(id)sender
{
    [ELA logOut:self];   
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showLockerSettings"]) {
        SettingsController * vc = [segue destinationViewController];
        XLFormRowDescriptor *row = (XLFormRowDescriptor *)sender;
        
        vc.parent = self;
        vc.rowDevice  = row;
        vc.userDevice = [ELA getUserDeviceById:row.tag];
        
    }
}



-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    
    if ([formRow.tag isEqualToString:@"unitType"]){
        BOOL useFahrenheit = [[newValue valueData] isEqualToString:self.tempF];
        [ELA setUseFahrenheit:useFahrenheit];
    }
    else if ([formRow.tag isEqualToString:@"weightType"]){
        BOOL isMetric = [[newValue valueData] isEqualToString: @"metric"];
        [ELA setUseMetric:isMetric];
    }
    else if ([formRow.tag isEqualToString:@"alertsEnabled"]){
        BOOL alertsEnabled = [[newValue valueData] boolValue];
        [ELA setAlertsEnabled: alertsEnabled];
    }
}


@end
