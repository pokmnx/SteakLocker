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
#import "DKScrollingTabController.h"
@import Charts;

@class MGScrollView;
@class LineChartView;
@class MGLineStyled;

@interface ReportsController : DropdownController <UIGestureRecognizerDelegate, UIScrollViewDelegate, ChartViewDelegate>

@property (nonatomic) float tempMin;
@property (nonatomic) float tempMax;
@property (nonatomic) float humidMin;
@property (nonatomic) float humidMax;
@property (nonatomic) float tempAvg;
@property (nonatomic) float humidAvg;
@property (nonatomic) float reportMin;
@property (nonatomic) float reportMax;
@property (nonatomic) float reportAvg;

@property (nonatomic) float warnTempMin;
@property (nonatomic) float warnTempMax;
@property (nonatomic) float warnHumidMin;
@property (nonatomic) float warnHumidMax;

@property (nonatomic) BOOL tempActive;
@property (nonatomic) BOOL hasData;
@property (nonatomic) int reportDays;
@property (nonatomic) NSString* reportCut;
@property (nonatomic, strong) NSDate *lastSync;

@property (nonatomic, strong) UILabel *lockerName;
@property (nonatomic, strong) UILabel *graphLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIButton *btnSupport;
@property (nonatomic, strong) MDRadialProgressView *radialTemp;
@property (nonatomic, strong) UILabel *radialLabelTemp;
@property (nonatomic, strong) MDRadialProgressView *radialHumid;
@property (nonatomic, strong) UILabel *radialLabelHumid;
@property (nonatomic, strong) MDRadialProgressView *radialReport;
@property (nonatomic, strong) UILabel *radialLabelReport;

@property (nonatomic, strong) UIView *segmentBg;
@property (nonatomic, strong) UISegmentedControl *reportSegments;
@property (nonatomic, strong) UIImageView * headImage;
@property (nonatomic, strong) UIImageView *graphBg;
@property (nonatomic, strong) UISegmentedControl *timeSegments;

@property (nonatomic, strong) DKScrollingTabController *tabController;

@property (nonatomic, strong) MGLineStyled *activeRow;


@property (nonatomic, strong) MGScrollView *scroller;

@property (nonatomic, strong) MGLineStyled *avgPrice;
@property (nonatomic, strong) MGLineStyled *avgLossPerc;
@property (nonatomic, strong) MGLineStyled *avgActualLossPerc;
@property (nonatomic, strong) MGLineStyled *avgServing;
@property (nonatomic, strong) MGLineStyled *avgNetCostPerc;
@property (nonatomic, strong) MGLineStyled *avgSalePrice;
@property (nonatomic, strong) MGLineStyled *avgNetCost;

@property (nonatomic, strong) LineChartView *chartView;

- (void) showImage: (UIImageView*)image show: (BOOL)show;

- (void)refreshData:(void (^)(BOOL))callback;

- (void)setCurrentTemp:(float)value;
- (void)setCurrentHumid:(float)value;

- (void)radialMeasurementSetup;

- (void)setTempActive;
- (void)setHumidActive;

- (void)handleScrollDown:(UITapGestureRecognizer *)recognizer;
- (void)handleScrollUp:(UITapGestureRecognizer *)recognizer;

- (IBAction)onMenu: (id)sender;
- (IBAction)onRefreshData;

- (void)ScrollingTabController:(DKScrollingTabController*)controller selection:(NSUInteger)selection;

@end

