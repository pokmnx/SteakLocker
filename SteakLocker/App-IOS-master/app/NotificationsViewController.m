//
//  NotificationsViewController.m
//  ELA
//
//  Created by Maxime Boulat on 6/14/17.
//  Copyright © 2017 ELA. All rights reserved.
//

#import "NotificationsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ELA.h"

@interface NotificationsViewController ()

@end

@implementation NotificationsViewController


#pragma mark - Lifecycle
#pragma mark


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _enableNotificationsButton.layer.cornerRadius = 22;
    _enableNotificationsButton.clipsToBounds = YES;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationsAuthorizationCallBack:) name: @"NotificationsAuthorization" object:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Actions
#pragma mark

- (IBAction)skipButtonTapped:(UIButton *)sender {
    [ELA startAddNewDevice:self];
}

- (IBAction)enableNotificationsButtonTapped:(UIButton *)sender {
    [ELA registerNotifications];
	
	
	// Pre ios8, no way to receive notifications authorization callback
	if (![[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
		 [ELA startAddNewDevice:self];
	}
}

#pragma mark - Notifications
#pragma mark


- (void) notificationsAuthorizationCallBack: (NSNotification *) notif {
	[ELA startAddNewDevice:self];
}


@end
