//
//  ProfileController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import "ProfileController.h"
#import <Parse/Parse.h>
#import "ELA.h"


@interface ProfileController () <MBProgressHUDDelegate>

@end

@implementation ProfileController
@synthesize hud;
@synthesize hudMsg;
@synthesize btnLogout;

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ELA addDropMenu:self.theMenu controller:self];
    
    self.tableView.backgroundColor  =[ELA getColorBGLight];
    self.view.backgroundColor = [ELA getColorBGLight];
    
    
    CGRect scrn = [[UIScreen mainScreen] bounds];
    btnLogout = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogout setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [btnLogout setBackgroundColor: [ELA getColorBGDark]];
    [btnLogout setTitle:@"Logout" forState: UIControlStateNormal];
    [btnLogout setFrame: CGRectMake(0, scrn.size.height - 60-64, scrn.size.width, 60)];
    [btnLogout addTarget:self action:@selector(onLogout) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview: btnLogout];

}

-(void)initializeForm
{
    self.theMenu = [ELA initDropMenu:self];
    
    PFUser *user = [PFUser currentUser];

    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    
    form = [XLFormDescriptor formDescriptor];
    
    // First section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
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

    
    self.form = form;
    self.form.delegate = self;

}


- (IBAction)onLogout
{
    [ELA logOut:self];
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
    self.theMenu.activeItemName = @"Profile";
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


-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    
    if ([formRow.tag isEqualToString:@"unitType"]){

        

    }
    else if ([formRow.tag isEqualToString:@"alertsEnabled"]){

    }
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

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hudWhat {
    
    if (hud) {
        // Remove HUD from screen when the HUD was hidded
        [hud removeFromSuperview];
        hud = nil;
    }
    if (hudMsg) {
        [hudMsg removeFromSuperview];
        hudMsg = nil;
    }
}

@end
