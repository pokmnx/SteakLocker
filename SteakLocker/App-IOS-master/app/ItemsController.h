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
#import "ProductTableView.h"
#import "BlogScroller.h"
#import <Parse/Parse.h>

@interface ItemsController : DropdownController <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic) float tempMin;
@property (nonatomic) float tempMax;
@property (nonatomic) float humidMin;
@property (nonatomic) float humidMax;


@property (nonatomic) BOOL tempActive;
@property (nonatomic, strong) MDRadialProgressView *radialTemp;
@property (nonatomic, strong) UILabel *radialLabelTemp;
@property (nonatomic, strong) MDRadialProgressView *radialHumid;
@property (nonatomic, strong) UILabel *radialLabelHumid;
@property (nonatomic, strong) MeasurementProgressView *viewTemp;
@property (nonatomic, strong) MeasurementProgressView *viewHumid;

@property (nonatomic, strong) UISegmentedControl *segments;
@property (nonatomic, strong) ProductTableView *tableItems;
@property (nonatomic, strong) ProductTableView *tableItemsPast;
@property (nonatomic, strong) UILabel *labelAddPrompt;
@property (nonatomic, strong) UIButton *btnAddPrompt;
@property (nonatomic, strong) UIImageView * headImage;
@property (nonatomic, strong) UIImageView * headLogo;
@property (nonatomic, strong) UILabel *headAgingType;


- (UIScrollView*)getScroll;

- (void)refreshObjects:(void (^)(BOOL))callback;

- (void)onItemAdded;

- (IBAction)onMenu: (id)sender;
- (IBAction)onAdd: (id)sender;
- (IBAction)onRefreshData;

@end

