//
//  NotificationsViewController.h
//  ELA
//
//  Created by Maxime Boulat on 6/14/17.
//  Copyright © 2017 ELA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *enableNotificationsButton;

- (IBAction)skipButtonTapped:(UIButton *)sender;
- (IBAction)enableNotificationsButtonTapped:(UIButton *)sender;

@end
