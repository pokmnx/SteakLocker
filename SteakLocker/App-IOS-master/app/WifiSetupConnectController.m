
//
//  SignInController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

@import UIKit;
#import "WifiSetupConnectController.h"
#import "ELA.h"
#import "ELADevice.h"
#import "FloatLabeledTextFieldCell.h"
#import "XLFormConnectionStatus.h"
#import "XLFormMacAddressCell.h"


@interface WifiSetupConnectController ()

@end

@implementation WifiSetupConnectController

@synthesize btnWifi;
@synthesize btnConnect;
@synthesize btnRead;
@synthesize btnSave;
@synthesize btnNormal;
@synthesize btnNext;
@synthesize btnCopy;

@synthesize connectedToDeviceWifi;
@synthesize sectionConnection;
@synthesize sectionWifiCreds;


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
}

- (IBAction)onBack: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext: (XLFormRowDescriptor *)sender
{
    [self deselectFormRow:sender];
     
    ELADevice * elaDevice = [ELA getElaDevice];    
    elaDevice.ssid = [self.rowSsid value];
    elaDevice.pass = [self.rowPass value];
    
    [self performSegueWithIdentifier:@"segueStatus" sender:self];
}

- (IBAction)onTapCopy:(XLFormRowDescriptor *)sender {
    
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

- (void)viewWillAppear:(BOOL)animated
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    [backButton setTintColor:[ELA getColorAccent]];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationIsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    NSLog(@"View Will Appear");
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [super viewWillAppear:animated];
}

-(void)setUpRechability
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
    
    NSLog(@"setUpRechability[%ld]", remoteHostStatus);
}

- (void) handleNetworkChange:(NSNotification *)notice
{
    if (self.reachability != nil) {
        NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
        
        NSLog(@"handleNetworkChange[%ld]", remoteHostStatus);

    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tableView.delaysContentTouches = false;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor  =[ELA getColorBGLight];
    self.view.backgroundColor = [ELA getColorBGLight];

    
    [ELA on:@"settingsRead" notify:^{
        [self onCheckConnection];
    }];
    
}

- (void)applicationIsActive:(NSNotification *)notification {
    [self onCheckConnection];
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    NSLog(@"Application Entered Foreground");
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? CGFLOAT_MIN : 40;
}

- (CGFloat)tableview:(UITableView *)tableView heightForFooterInSection: (NSInteger) section
{
    return (section == 0) ? 101 : 40;
}

-(void)initializeForm
{
    XLFormDescriptor *form;
    XLFormSectionDescriptor * section;
    XLFormSectionDescriptor * bssidSection;

    
    form = [XLFormDescriptor formDescriptor];
    
    NSString *ssid = [ELA getWifiSSID];
    
    sectionConnection = [XLFormSectionDescriptor formSection];
    sectionConnection.title = nil;
    
    self.rowConnection = [XLFormRowDescriptor formRowDescriptorWithTag:@"connectionStatus" rowType:XLFormRowDescriptorTypeConnectionStatus];
    [sectionConnection addFormRow:self.rowConnection];
    
    [form addFormSection:sectionConnection];

	ELADevice *elaDevice = [ELA getElaDevice];
	BOOL connected = [elaDevice isConnectedToDeviceWifi];

	if (connected && elaDevice.uniqueId != nil) {

		sectionWifiCreds = [XLFormSectionDescriptor formSectionWithTitle:@"Your Network Details"];
		sectionWifiCreds.footerTitle = @"Network Name and Passwords are case sensitive.";

		self.rowSsid = [XLFormRowDescriptor formRowDescriptorWithTag:@"ssid" rowType:XLFormRowDescriptorTypeFloatLabeledTextField title:@"Network"];

		if (![ssid isEqualToString:[ELA getDeviceWifiName]]) {
			[self.rowSsid setValue: ssid];
		}
		[sectionWifiCreds addFormRow:self.rowSsid];

		self.rowPass = [XLFormRowDescriptor formRowDescriptorWithTag:@"pass" rowType:XLFormRowDescriptorTypeFloatLabeledTextField title:@"Password"];
		[sectionWifiCreds addFormRow:self.rowPass];

		[form addFormSection:sectionWifiCreds];
        
        bssidSection = [XLFormSectionDescriptor formSection];
        [form addFormSection:bssidSection];
        self.rowBssid = [XLFormRowDescriptor formRowDescriptorWithTag:@"macAddress" rowType:XLFormRowDescriptorTypeMacAddress];
        [bssidSection addFormRow:self.rowBssid];
        
		section = [XLFormSectionDescriptor formSection];
		[form addFormSection:section];
		// Button
		self.buttonRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"finishSetup" rowType:XLFormRowDescriptorTypeButton title:@"Finish"];
		[self.buttonRow.cellConfig setObject:[ELA getColorAccent] forKey:@"backgroundColor"];
		[self.buttonRow.cellConfig setObject:[UIColor whiteColor] forKey:@"textLabel.textColor"];
		[self.buttonRow.cellConfig setObject:[ELA getFont:20.0f] forKey:@"textLabel.font"];
		
		self.buttonRow.action.formSelector = @selector(onNext:);
		[section addFormRow:self.buttonRow];
		
	}

    self.form = form;
    self.form.delegate = self;

	XLFormConnectionStatusCell *cell;
	cell = (XLFormConnectionStatusCell*)[self.rowConnection cellForFormController:self];
	if (cell != nil) {
		[cell updateMe: elaDevice];
	}

}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    ELADevice *elaDevice = [ELA getElaDevice];
    BOOL connected = [elaDevice isConnectedToDeviceWifi];
    if (connected && elaDevice.uniqueId != nil) {
        if (indexPath.row == 1 && indexPath.section == 1) {
            CGRect scrn = [ELA getScreen];
            UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrn.size.width, 1)];
            [seperator setBackgroundColor:[UIColor colorWithRed:192.0f / 255.0f green:192.0f / 255.0f blue:192.0f / 255.0f alpha:1.0f]];
            [cell.contentView addSubview:seperator];
        }
    }
    
    return cell;
}

- (void)onCheckConnection
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self initializeForm];
	});
}

@end
