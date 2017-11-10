//
//  ViewController.h
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropdownController.h"
#import "MeasurementProgressView.h"
#import "MBProgressHUD.h"
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"
#import <Parse/Parse.h>

@interface DashboardController : DropdownController <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSString *impeeId;

@property (nonatomic) float tempMin;
@property (nonatomic) float tempMax;
@property (nonatomic) float humidMin;
@property (nonatomic) float humidMax;


@property (nonatomic, strong) UILabel *lockerName;
@property (nonatomic, strong) UILabel * lastUpdated;
@property (nonatomic, strong) UIView * notConnectedBanner;
@property (nonatomic) BOOL tempActive;
@property (nonatomic, strong) MDRadialProgressView *radialTemp;
@property (nonatomic, strong) UILabel *radialLabelTemp;
@property (nonatomic, strong) MDRadialProgressView *radialHumid;
@property (nonatomic, strong) UILabel *radialLabelHumid;
@property (nonatomic, strong) MeasurementProgressView *viewTemp;
@property (nonatomic, strong) MeasurementProgressView *viewHumid;

@property (nonatomic, strong) UIImageView * headImage;
@property (nonatomic, strong) UIImageView * headLogo;
@property (nonatomic, strong) UILabel *headAgingType;

@property (nonatomic, strong) UILabel* warningLabel;
@property (nonatomic, strong) UIButton* helpButton;


- (UIScrollView*)getScroll;

- (void)updateScrollHeight;

- (void) showImage: (UIImageView*)image show: (BOOL)show;

- (void)refreshData:(void (^)(BOOL))callback;

- (void)setCurrentTemp:(float)value;
- (void)setCurrentHumid:(float)value;

- (void)radialMeasurementSetup;

- (void)setTempActive;
- (void)setHumidActive;

- (void)handleScrollDown:(UITapGestureRecognizer *)recognizer;
- (void)handleScrollUp:(UITapGestureRecognizer *)recognizer;

- (void)updateData:(NSTimer*) timer;

- (IBAction)onMenu: (id)sender;
- (IBAction)onAdd: (id)sender;
- (IBAction)onRefreshData;
- (IBAction)onLogout;

@end

