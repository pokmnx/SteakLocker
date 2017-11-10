//
//  SettingsController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import "SettingsController.h"
#import <Parse/Parse.h>
#import "ELA.h"



@interface SettingsController ()

@end

@implementation SettingsController

@synthesize agingTypeRow;
@synthesize hud;
@synthesize hudMsg;
@synthesize warningOldType;
@synthesize warningNewType;
@synthesize formDevice;
@synthesize setTemperatureEnabled;
@synthesize setHumidityEnabled;
@synthesize userDevice;
@synthesize nickname;



NSString *const kRowAgingType = @"agingType";
NSString *const kRowTempDryAging = @"temperatureDryAging";
NSString *const kRowTempCharcuterie = @"temperatureCharcuterie";
NSString *const kRowHumidDryAging = @"humidityDryAging";
NSString *const kRowHumidCharcuterie = @"humidityCharcuterie";

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        //[self initializeForm];
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeForm];
    self.tableView.backgroundColor  =[ELA getColorBGLight];
    self.view.backgroundColor = [ELA getColorBGLight];

    self.theMenu = [ELA initDropMenuAndAdd:self];
}
-(void)initializeForm
{
    setTemperatureEnabled = [ELA getConfigBool:@"setTemperatureEnabled"];
    setHumidityEnabled = [ELA getConfigBool:@"setHumidityEnabled"];

    self.formDevice = [XLFormDescriptor formDescriptor];
    
    [self addDeviceSettings:userDevice];




    XLFormRowDescriptor * row;
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSection];
    [self.formDevice addFormSection:section];



    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"update" rowType:XLFormRowDescriptorTypeButton title: @"Update Locker Network Settings"];

    row.height = 70.0f;

    [row.cellConfig setObject:[ELA getColorBGLight] forKey:@"backgroundColor"];
    [row.cellConfig setObject:[ELA getColorAccent] forKey:@"textLabel.textColor"];
    //[row.cellConfig setObject:[ELA getFont:20.0f] forKey:@"textLabel.font"];

    // Do this to hack the XLForm button to be rounded, since is actually a tableviewcell masquerading as a button
    [row.cellConfig setObject:@(YES) forKey:@"clipsToBounds"];
    [row.cellConfig setObject:@(15.0f) forKey:@"layer.borderWidth"];
    [row.cellConfig setObject:[ELA getColorBGLight].CGColor forKey:@"layer.borderColor"];

    row.action.formBlock = ^(XLFormRowDescriptor * sender){
        [ELA loadStoryboard:self storyboard:@"SetupChooser"];
    };
    [section addFormRow:row];
    

    self.form = self.formDevice;
    self.form.delegate = self;
    
}

- (void)addDeviceSettings: (PFObject *)device
{
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    NSString *agingType = [ELA getDeviceAgingType:device];
    
    NSString * name = [device objectForKey:@"nickname"];
    NSString * sectionTitle = [NSString stringWithFormat:@"%@ Settings", name];
    
    section = [XLFormSectionDescriptor formSectionWithTitle: sectionTitle];
    
    [formDevice addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"nickname" rowType:XLFormRowDescriptorTypeText title:@"Locker Name"];
    row.required = YES;
    row.value = name;
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    
    if (![ELA isDeviceActive:device]) {
        self.rowActive = [XLFormRowDescriptor formRowDescriptorWithTag:@"active" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Active Locker"];
        [section addFormRow:self.rowActive];
    }
    
    
    
    row = [self getAgingTypeRow: device];
    [section addFormRow:row];
    
    // Dry Aging: 34-38f
    // Charcuter: 53-60f
    if (setTemperatureEnabled) {
        if ([agingType isEqualToString: TYPE_DRYAGING]) {
            row = [self getTemperatureRowDryAging: device];
        }
        else {
            row = [self getTemperatureRowCharcuterie: device];
        }
        [section addFormRow:row];
    }
    
    
    if (setHumidityEnabled) {
        if ([agingType isEqualToString: TYPE_DRYAGING]) {
            row = [self getHumidityRowDryAging:device];
        }
        else {
            row = [self getHumidityRowCharcuterie:device];
        }
        [section addFormRow:row];
    }

}

- (XLFormRowDescriptor*)getAgingTypeRow: (PFObject *)device
{
    agingTypeRow = [XLFormRowDescriptor formRowDescriptorWithTag:kRowAgingType rowType:    XLFormRowDescriptorTypeSelectorPush title:@"Aging Type"];
    
    NSMutableArray *ageTypes = [[NSMutableArray alloc] init];
    [ageTypes addObject:[XLFormOptionsObject formOptionsObjectWithValue:TYPE_DRYAGING displayText:TYPE_DRYAGING]];
    [ageTypes addObject:[XLFormOptionsObject formOptionsObjectWithValue:TYPE_CHARCUTERIE displayText:TYPE_CHARCUTERIE]];
    agingTypeRow.selectorOptions = ageTypes;
    agingTypeRow.required = YES;
    agingTypeRow.value = [ELA getDeviceAgingType: device];

    return agingTypeRow;
}


- (XLFormRowDescriptor*)getTemperatureRow: (PFObject *)device key:(NSString*)key tag:(NSString*)tag
{
    XLFormRowDescriptor * row;
    row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Temperature"];
    
    NSMutableArray *opts = [[NSMutableArray alloc] init];
    int min = [ELA getConfigInt: [NSString stringWithFormat:@"temp%@Min", key]];
    int max = [ELA getConfigInt: [NSString stringWithFormat:@"temp%@Max", key]];
    float f;
    NSString *s;
    for(int i=min; i<=max; i++) {
        f = [ELA fahrenheitToCelsius: i];
        s = [NSString stringWithFormat:@"%d° F  /  %.2f° C", i, f];
        
        [opts addObject:[XLFormOptionsObject formOptionsObjectWithValue:@(i) displayText:s]];
    }
    
    row.selectorOptions = opts;
    // @TODO FIX
    //row.cellReturnKeyType = UIReturnKeyDone;
    
    float tempF = [ELA celsiusToFahrenheit:[ELA getDeviceTemperature: device] round:YES];
    
    if (tempF < min) {
        tempF = min;
    }
    else if (tempF > max) {
        tempF = max;
    }
    
    for (XLFormOptionsObject *obj in row.selectorOptions) {
        if ([[obj valueData] integerValue] == (int)tempF) {
            row.value = obj;
        }
    }
    
    return row;
}



- (XLFormRowDescriptor*)getWeightRow: (PFObject *)device key:(NSString*)key tag:(NSString*)tag
{
    XLFormRowDescriptor * row;
    row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Temperature"];
    
    NSMutableArray *opts = [[NSMutableArray alloc] init];
    int min = [ELA getConfigInt: [NSString stringWithFormat:@"temp%@Min", key]];
    int max = [ELA getConfigInt: [NSString stringWithFormat:@"temp%@Max", key]];
    float f;
    NSString *s;
    for(int i=min; i<=max; i++) {
        f = [ELA fahrenheitToCelsius: i];
        s = [NSString stringWithFormat:@"%d° F  /  %.2f° C", i, f];
        
        [opts addObject:[XLFormOptionsObject formOptionsObjectWithValue:@(i) displayText:s]];
    }
    
    row.selectorOptions = opts;
    // @TODO FIX
    //row.cellReturnKeyType = UIReturnKeyDone;
    
    float tempF = [ELA celsiusToFahrenheit:[ELA getDeviceTemperature: device] round:YES];
    
    if (tempF < min) {
        tempF = min;
    }
    else if (tempF > max) {
        tempF = max;
    }
    
    for (XLFormOptionsObject *obj in row.selectorOptions) {
        if ([[obj valueData] integerValue] == (int)tempF) {
            row.value = obj;
        }
    }
    
    return row;
}




- (XLFormRowDescriptor*)getTemperatureRowDryAging: (PFObject*)device
{
    return [self getTemperatureRow:device key:@"DryAging" tag: kRowTempDryAging];
}
- (XLFormRowDescriptor*)getTemperatureRowCharcuterie: (PFObject*)device
{
    return [self getTemperatureRow:device key:@"Charcuterie" tag: kRowTempCharcuterie];
}
- (XLFormRowDescriptor*)getHumidityRow:(PFObject *)device key:(NSString*)key tag:(NSString*)tag
{
    XLFormRowDescriptor * row;
    row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Humidity"];
    
    NSMutableArray *opts = [[NSMutableArray alloc] init];
    int min = [ELA getConfigInt: [NSString stringWithFormat:@"humid%@Min", key]];
    int max = [ELA getConfigInt: [NSString stringWithFormat:@"humid%@Max", key]];
    NSString *s;
    for(int i=min; i<=max; i++) {
        s = [NSString stringWithFormat:@"%d %%", i];
        [opts addObject:[XLFormOptionsObject formOptionsObjectWithValue:@(i) displayText:s]];
    }
    
    row.selectorOptions = opts;
    // @TODO FIX
    //row.cellReturnKeyType = UIReturnKeyDone;
    
    float humid = [ELA getDeviceHumidity: device];
    if (humid < min) {
        humid = min;
    }
    else if (humid > max) {
        humid = max;
    }
    
    for (XLFormOptionsObject *obj in row.selectorOptions) {
        if ([[obj valueData] integerValue] == (int)humid) {
            row.value = obj;
        }
    }
    
    return row;
}



- (XLFormRowDescriptor*)getHumidityRowDryAging: (PFObject*)device
{
    return [self getHumidityRow:device key:@"DryAging" tag:kRowHumidDryAging];
}
- (XLFormRowDescriptor*)getHumidityRowCharcuterie: (PFObject*)device
{
    return [self getHumidityRow:device key:@"Charcuterie" tag: kRowHumidCharcuterie];

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

- (IBAction)onBack: (id)sender
{
    NSString *deviceNickname = [userDevice objectForKey:@"nickname"];
    if (nickname != nil) {
        if (deviceNickname == nil || ![nickname isEqualToString:deviceNickname]) {
            [ELA deviceSetNickname:userDevice nickname:nickname];
        }
    }
    
    
    BOOL active = (self.rowActive != nil) ? [self.rowActive.value boolValue] : NO;
    if (active) {
        [ELA setUserDevice:userDevice];
    }
    
    if (self.rowDevice != nil) {
        if (nickname != nil) {
            [self.rowDevice setTitle:nickname];
        }
    }
    
    [self.parent updateDevices];
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    
    PFObject *device = userDevice;
    
    if ([formRow.tag isEqualToString:@"nickname"]){
        nickname = (NSString*)newValue;
    }
    else if ([formRow.tag isEqualToString:@"agingType"]){
        BOOL enabled = [ELA userHasCharcuterieEnabled];
        BOOL isCharcuterie = [[newValue valueData] isEqualToString:TYPE_CHARCUTERIE];
        
        if (!enabled) {
            if (isCharcuterie) {
                [self showGetCodeEnterCode];
            }
        }
        else {
            NSString *oldAgingType = (device != nil) ? [ELA getDeviceAgingType:device] : [ELA getAgingType];
            NSString *agingType = (isCharcuterie) ? TYPE_CHARCUTERIE : TYPE_DRYAGING;
            
            if ([agingType isEqualToString:oldAgingType]) {
                [ELA deviceSetAgingType:device agingType:agingType];
            }
            else {
                [self warnIfNecessary:device oldAgingType:oldAgingType newAgingType:agingType];
            }
            
            if (setTemperatureEnabled) {
                if (![agingType isEqualToString:oldAgingType]) {
                    if ([oldAgingType isEqualToString:TYPE_DRYAGING]) {
                        [self.form removeFormRowWithTag:kRowTempDryAging];
                        [self.form addFormRow:[self getTemperatureRowCharcuterie:device] afterRow:agingTypeRow];
                    }
                    else if ([oldAgingType isEqualToString:TYPE_CHARCUTERIE]) {
                        [self.form removeFormRowWithTag:kRowTempCharcuterie];
                        [self.form addFormRow:[self getTemperatureRowDryAging:device] afterRow:agingTypeRow];
                    }
                }
            }
            if (setHumidityEnabled) {
                if (![agingType isEqualToString:oldAgingType]) {
                    if ([oldAgingType isEqualToString:TYPE_DRYAGING]) {
                        [self.form removeFormRowWithTag:kRowHumidDryAging];
                        [self.form addFormRow:[self getHumidityRowCharcuterie:device] afterRow:agingTypeRow];
                    }
                    else if ([oldAgingType isEqualToString:TYPE_CHARCUTERIE]) {
                        [self.form removeFormRowWithTag:kRowHumidCharcuterie];
                        [self.form addFormRow:[self getHumidityRowDryAging:device] afterRow:agingTypeRow];
                    }
                }
            }
        }
    }
    else if ([formRow.tag isEqualToString: kRowTempDryAging]) {
        [ELA deviceSetTemperature:device temp:[[newValue valueData] floatValue]];
    }
    else if ([formRow.tag isEqualToString: kRowTempCharcuterie]) {
    //    [self.tableView endEditing:YES];
        [ELA deviceSetTemperature:device temp:[[newValue valueData] floatValue]];
    }
    
    else if ([formRow.tag isEqualToString: kRowHumidDryAging]) {
  //      [self.tableView endEditing:YES];
        [ELA deviceSetHumidity:device humidity:[[newValue valueData] floatValue]];
    }
    else if ([formRow.tag isEqualToString: kRowHumidCharcuterie]) {
//        [self.tableView endEditing:YES];
        [ELA deviceSetHumidity:device humidity:[[newValue valueData] floatValue]];
    }
}

- (void)showGetCodeEnterCode
{
    NSString *msg = [ELA getConfigString: @"enableFeatureMessage"];
    if (msg == nil) {
        msg = @"";
    }
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Enable Premium Feature"
                                                      message:msg
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Get Code", @"Enter Code", nil];
    [message show];
}

- (void)showEnableCharcuterie
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Enable Premium Feature"
                                                      message:@"Enter code (case sensitive):"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Use Code", nil];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [message show];
}

- (void)warnIfNecessary: (PFObject*)device oldAgingType:(NSString *)oldAgingType newAgingType:(NSString *)newAgingType
{
    // @TODO Count by device, not recent
    int count = [ELA getCountLatestUserObjects: newAgingType];
    if (count > 0) {
        self.warningOldType = oldAgingType;
        self.warningNewType = newAgingType;
        [self showAgingTypeChangeWarning:newAgingType];
    }
    else {
        if (device != nil) {
            [ELA deviceSetAgingType:device agingType:newAgingType];
        }
    }
}

- (void)showAgingTypeChangeWarning: (NSString *)newAgingType
{
    PFConfig *config = [PFConfig getConfig];
    NSString *message = config[@"typeChangeWarning"];
    NSString *title = [NSString stringWithFormat:@"Change to %@", newAgingType];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                      message:[message stringByReplacingOccurrencesOfString:@"[type]" withString:newAgingType]
                                                     delegate:self
                                            cancelButtonTitle:@"Nevermind"
                                            otherButtonTitles:@"I Understand, Change It"
                                            , nil];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Use Code"])
    {
        UITextField *textCode = [alertView textFieldAtIndex:0];
        NSString *code = textCode.text;
        [self validateCode: code];
    }
    else if ([title isEqualToString:@"Get Code"]) {
        PFConfig *config = [ELA getConfig];
        NSString *url = nil;
        if (config != nil) {
            url = (NSString*)[config objectForKey:@"getFeatureCodeUrl"];
        }
        if (url == nil) {
            url = @"http://www.steaklocker.com/";
        }
        
        if (url != nil){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        [self showEnableCharcuterie];
    }
    else if ([title isEqualToString:@"Enter Code"]) {
        [self showEnableCharcuterie];
    }
    else if ([title isEqualToString:@"Nevermind"]) {
        [ELA userSetAgingType:self.warningOldType];
        agingTypeRow.value = self.warningOldType;
        [self reloadFormRow: agingTypeRow];
        self.warningOldType = nil;
        self.warningNewType = nil;
    }
    else if ([title isEqualToString:@"I Understand, Change It"]) {
        [ELA userSetAgingType:self.warningNewType];
        agingTypeRow.value = self.warningNewType;
        [self reloadFormRow: agingTypeRow];
        self.warningOldType = nil;
        self.warningNewType = nil;
    }
    else {
//        BOOL enabled = [ELA userHasCharcuterieEnabled];
        agingTypeRow.value = TYPE_DRYAGING;
        [self reloadFormRow: agingTypeRow];
    }
}

- (void)validateCode: (NSString*)code
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.dimBackground = YES;
    hud.labelText = @"Validating ...";
    
    PFUser *user = [PFUser currentUser];

    [PFCloud callFunctionInBackground:@"useFeatureCode"
        withParameters:@{@"code": code, @"feature": TYPE_CHARCUTERIE, @"userId": user.objectId}
        block:^(NSString *status, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            hudMsg = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hudMsg.mode = MBProgressHUDModeCustomView;
            [hudMsg hide:YES afterDelay:3];

            if (!error) {
                hudMsg.labelText = @"Charcuterie enabled";
                [ELA userEnableCharcuterie];

                [self warnIfNecessary: nil oldAgingType:TYPE_DRYAGING newAgingType:TYPE_CHARCUTERIE];
            }
            else {
                hudMsg.labelText =(NSString*)error.userInfo[@"error"];
                agingTypeRow.value = TYPE_DRYAGING;
                [self reloadFormRow: agingTypeRow];
            }
        }];
}
-(void)showErrorMsg:(NSString *)msg
{
    hudMsg = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hudMsg.mode = MBProgressHUDModeCustomView;
    hudMsg.labelText = msg;
    
    [hudMsg hide:YES afterDelay:2];
}


@end
