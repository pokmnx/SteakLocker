//
//  ReportsController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import "ReportsController.h"
#import <Parse/Parse.h>
#import "DropdownController.h"
#import "ELA.h"
#import "ItemController.h"
#import "ObjectController.h"

#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"
@import Charts;

@interface ReportsController ()

- (int)getHeaderHeight;
- (void)scrollToTop;

@end

MGBox *tablesReportGrid, *tableReport;
NSMutableArray *cutNames, *cutIds;

@implementation ReportsController

@synthesize headImage;
@synthesize radialTemp;
@synthesize radialLabelTemp;
@synthesize radialHumid;
@synthesize radialLabelHumid;
@synthesize radialReport;
@synthesize radialLabelReport;
@synthesize reportSegments;
@synthesize segmentBg;
@synthesize graphLabel;
@synthesize lockerName;
@synthesize infoLabel;
@synthesize btnSupport;

@synthesize tabController;
@synthesize scroller;

@synthesize avgPrice;
@synthesize avgLossPerc;
@synthesize avgActualLossPerc;
@synthesize avgServing;
@synthesize avgNetCostPerc;
@synthesize avgSalePrice;
@synthesize avgNetCost;
@synthesize graphBg;
@synthesize timeSegments;
@synthesize chartView;

/*
- (UIScrollView*)getScroll
{
    return (UIScrollView*)self.view;
}
 */
- (int)getHeaderHeight
{
    return self.navigationController.navigationBar.frame.size.height + [ELA getStatusBarHeight];
}
- (void)scrollToTop
{
    /*
    CGPoint point = CGPointMake(headImage.frame.origin.x, headImage.frame.origin.y);
    //point.y -= [self getHeaderHeight];
    [[self getScroll] setContentOffset:point animated:YES];
     */
}



-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.view bringSubviewToFront:radialTemp];
    [self.view bringSubviewToFront:radialLabelTemp];
    [self.view bringSubviewToFront:radialHumid];
    [self.view bringSubviewToFront:radialLabelHumid];
    [self.view bringSubviewToFront:segmentBg];
    [self.view bringSubviewToFront:reportSegments];
    [self.view bringSubviewToFront:graphLabel];
    [self.view bringSubviewToFront:lockerName];
    [self.view bringSubviewToFront:infoLabel];
    [self.view bringSubviewToFront:btnSupport];
//    [self.view bringSubviewToFront:scroller];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Customize your menubar programmatically here.

    self.tempMin = 0.0f;
    self.tempMax = 35.0f;
    self.humidMin = 0;
    self.humidMax = 100.0f;
    

        PFObject *device = [ELA getUserDevice];
        NSString *deviceObjectId = (device == nil) ? nil : device.objectId;
        NSString* agingType = [ELA getDeviceAgingType:device];
        BOOL isCharcuterie = [agingType isEqualToString:TYPE_CHARCUTERIE];
        if (isCharcuterie) {
            self.warnTempMin  = [ELA fahrenheitToCelsius:[ELA getConfigFloat:@"tempCharcuterieMin"]];
            self.warnTempMax  = [ELA fahrenheitToCelsius:[ELA getConfigFloat:@"tempCharcuterieMax"]];
            self.warnHumidMin = [ELA getConfigFloat:@"humidCharcuterieMin"];
            self.warnHumidMax = [ELA getConfigFloat:@"humidCharcuterieMax"];
        }
        else {
            self.warnTempMin  = [ELA fahrenheitToCelsius:[ELA getConfigFloat:@"tempDryAgingMin"]];
            self.warnTempMax  = [ELA fahrenheitToCelsius:[ELA getConfigFloat:@"tempDryAgingMax"]];
            self.warnHumidMin = [ELA getConfigFloat:@"humidDryAgingMin"];
            self.warnHumidMax = [ELA getConfigFloat:@"humidDryAgingMax"];
        }
    
    
    self.hasData = false;
    self.tempActive = true;
    
    UINavigationBar *bar = self.navigationController.navigationBar;
    
    [bar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [bar setShadowImage:[UIImage new]];
    
    CGRect scrn = [ELA getScreen];
    
    [self.view setBackgroundColor: [ELA getColorBGLight]];
    
    float c = 245.0f/ 255.0f;
    CGRect frameSegment = CGRectMake(0, 0, scrn.size.width, 40);
    segmentBg = [[UIView alloc] initWithFrame:frameSegment];
    [segmentBg setBackgroundColor:[UIColor colorWithRed:c green:c blue:c alpha:1.0f]];
    [self.view addSubview:segmentBg];
    

    BOOL isPro = [ELA isProUser];
    NSArray *itemArray = isPro ? [NSArray arrayWithObjects: @"Temperature", @"Humidity", @"Yield", nil] :
                                [NSArray arrayWithObjects: @"Temperature", @"Humidity", nil];
    reportSegments = [[UISegmentedControl alloc] initWithItems:itemArray];
    [reportSegments setFrame: CGRectMake(15, 5, scrn.size.width-30, 25)];
    [reportSegments setTintColor:[ELA getColorAccent]];
    
    [reportSegments addTarget:self action:@selector(onReportSegment:) forControlEvents: UIControlEventValueChanged];
    reportSegments.selectedSegmentIndex = 0;
    [self.view addSubview:reportSegments];
    
    
    float headHeight = [ELA getHeaderHeight:self];
    int imgHeight = (int)(self.view.frame.size.height - frameSegment.size.height);
    NSString *sImage = [ELA isProUser] ? @"BGDashboardPro" : @"BGDashboard";
    headImage = [ELA addImage:sImage X:0 Y:frameSegment.size.height W:scrn.size.width H:imgHeight-headHeight];
    [headImage setClipsToBounds:YES];
    [headImage setContentMode:UIViewContentModeScaleAspectFill];
    
    [self.view addSubview:headImage];
    [self.view sendSubviewToBack:headImage];
    
    
    int radialWidth = (int)(scrn.size.width - 100);
    int radialTop   = (imgHeight - radialWidth) / 2.0f;


    lockerName = [[UILabel alloc] initWithFrame:CGRectMake(0, radialTop-85, scrn.size.width, 20)];
    if (device != nil) {
        [lockerName setText: (NSString*)[device objectForKey:@"nickname"]];
    }
    [lockerName setTextAlignment:NSTextAlignmentCenter];
    [lockerName setTextColor:[UIColor whiteColor]];
    [lockerName setFont: [ELA getFont:18]];
    [self.view addSubview:lockerName];

    
    
    graphLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, radialTop-50, scrn.size.width, 25)];
    [graphLabel setFont: [ELA getFontThin:22]];
    [graphLabel setText:@"Last 30 Days"];
    [graphLabel setTextAlignment:NSTextAlignmentCenter];
    [graphLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:graphLabel];
    
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, radialTop+radialWidth+15, scrn.size.width, 35)];
    [infoLabel setFont: [ELA getFontThin:16]];
    [infoLabel setText:@""];
    [infoLabel setTextAlignment:NSTextAlignmentCenter];
    [infoLabel setTextColor:[UIColor whiteColor]];
    [infoLabel setNumberOfLines:2];
    [self.view addSubview:infoLabel];
    
    
    btnSupport = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSupport setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    UIImage *bg = [ELA imageWithColor: [ELA getColorAccent]];
    [btnSupport setBackgroundImage:bg forState:UIControlStateNormal];
    
    
    [btnSupport setTitle:@"Support" forState: UIControlStateNormal];
    float headerHeight = [ELA getHeaderHeight:self];
    [btnSupport setFrame: CGRectMake(25, self.view.frame.size.height - 60 -headerHeight, scrn.size.width-50, 46)];
    
    [btnSupport setClipsToBounds:YES];
    btnSupport.layer.cornerRadius = 23;
    btnSupport.layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.0f].CGColor;
    
    [btnSupport addTarget:self action:@selector(onSupport) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: btnSupport];
    
    
    
    CGRect radialFrame = CGRectMake((scrn.size.width-radialWidth)/2, radialTop, radialWidth, radialWidth);
    radialTemp = [[MDRadialProgressView alloc] initWithFrame:radialFrame];
    radialLabelTemp = [[UILabel alloc] initWithFrame:CGRectMake(0, radialFrame.origin.y+(radialWidth/3.6f), scrn.size.width, 25)];
    radialHumid = [[MDRadialProgressView alloc] initWithFrame:radialFrame];
    radialLabelHumid = [[UILabel alloc] initWithFrame:CGRectMake(0, radialFrame.origin.y+(radialWidth/3.6f), scrn.size.width, 25)];
    
    [self radialMeasurementSetup];
    
    [self onReportSegment: reportSegments];

    
    
    
    
    int offset = headHeight;
    

    CGRect frame = CGRectMake(0, offset+0, scrn.size.width, 80);
    
    frame.origin.y += frame.size.height;
    frame.size.height = 40;

    CGRect framePrompt = frame;
    framePrompt.size.height = 40;
    

    
    CGRect graphBgRect = headImage.frame;
    graphBgRect.size.height = graphBgRect.size.width / 1.33;
    //int y = (headImage.frame.size.height / 2) - (graphBgRect.size.height / 2);
    CGRect blurRect = graphBgRect;
    blurRect.origin.y = headImage.frame.size.height - blurRect.size.height;

    UIImage *blurredImage = [ELA blurredSnapshot:headImage size:headImage.size frame:blurRect radius:0.0f];
    
    graphBg = [[UIImageView alloc] initWithFrame:graphBgRect];
    [graphBg setImage:blurredImage];
    [self.view addSubview:graphBg];
    
    
    
    CGRect radialReportFrame = graphBgRect;
    
    CGRect graphFrame = graphBg.frame;
    CGRect labelFrame = graphLabel.frame;
    radialWidth = (int)(scrn.size.width / 2);
    int radialHeight = graphFrame.size.height - (labelFrame.origin.y+labelFrame.size.height) + graphFrame.origin.y;
    if (radialWidth > radialHeight) {
        radialWidth = radialHeight;
    }
    else if (radialWidth < radialHeight) {
        radialHeight = radialWidth;
    }
    radialTop   = graphFrame.size.height - radialHeight + (graphFrame.origin.y / 2);
    radialReportFrame = CGRectMake((scrn.size.width-radialWidth)/2, radialTop, radialWidth, radialHeight);
    
    
    
    radialReport = [[MDRadialProgressView alloc] initWithFrame:radialReportFrame];
    radialLabelReport = [[UILabel alloc] init];
    [self radialReportSetup];
    

    NSArray *timeArray = [NSArray arrayWithObjects: @"All", @"1 Month", @"3 Months", @"6 Months", @"1 Year", nil];
    timeSegments = [[UISegmentedControl alloc] initWithItems:timeArray];
    [timeSegments setFrame: CGRectMake(15, 55, scrn.size.width-30, 25)];
    [timeSegments setTintColor: [UIColor whiteColor]];
    
    [timeSegments addTarget:self action:@selector(onTimeSegment:) forControlEvents: UIControlEventValueChanged];
    timeSegments.selectedSegmentIndex = 0;
    [self.view addSubview:timeSegments];
    
    
    
    tabController = [[DKScrollingTabController alloc] init];
    tabController.delegate = self;
    
    CGRect frameCutChooser = CGRectMake(0, graphBgRect.origin.y+graphBgRect.size.height, scrn.size.width, 50);
    [self addChildViewController: tabController];
    tabController.view.frame = frameCutChooser;
    [self.view addSubview: tabController.view];
    [tabController didMoveToParentViewController: self];

    tabController.view.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f];
    tabController.buttonPadding = 20;
    tabController.underlineIndicator = YES;
    tabController.underlineIndicatorColor = [ELA getColorAccent];
    tabController.buttonsScrollView.showsHorizontalScrollIndicator = NO;
    tabController.selectedBackgroundColor = [UIColor clearColor];
    tabController.selectedTextColor = [UIColor blackColor];
    tabController.unselectedTextColor = [UIColor grayColor];
    tabController.unselectedBackgroundColor = [UIColor clearColor];
    tabController.startingIndex = 0;
    tabController.buttonTitleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    cutNames = [[NSMutableArray alloc] init];
    cutIds   = [[NSMutableArray alloc] init];
    [cutNames addObject:@"All Cuts"];
    [cutIds addObject:@"all"];
    RLMResults * items = [Object getAll];
    for (Object *obj in items) {
        if ([obj isAgingType:agingType] && [UserObject existsForObject:obj.objectId device:deviceObjectId]) {
            [cutNames addObject: obj.title];
            [cutIds addObject: obj.objectId];
        }
    }
    if ([UserObject existsForObject:nil device:deviceObjectId]) {
        [cutNames addObject: @"Custom"];
        [cutIds addObject: @"custom"];
    }
    tabController.selection = cutNames;
    
    
    [tabController.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *button = obj;
        
        [button.titleLabel setFont: [ELA getFont:16]];
    }];
    [self ScrollingTabController:tabController selection:0];
    
    
    
    
    
    CGRect frameChartList = CGRectMake(0, frameCutChooser.origin.y+frameCutChooser.size.height, scrn.size.width, headImage.frame.size.height - graphBgRect.size.height - frameCutChooser.size.height);
    self.scroller = [[MGScrollView alloc] initWithFrame:frameChartList];
    
    self.scroller.bounces = NO;
    
    CGSize rowSize  = CGSizeMake(scrn.size.width, 60);
    
    [self.scroller.boxes removeAllObjects];

    
    // the features table
    tableReport = MGBox.box;
    [self.scroller.boxes addObject:tableReport];
    tableReport.sizingMode = MGResizingShrinkWrap;

    // intro section
    MGTableBox *box = MGTableBox.box;
    [tableReport.boxes addObject:box];
    
    BOOL isMetric = [ELA isMetric];
    
    __weak ReportsController *me = self;
    
    NSString *label = isMetric ? @"Average Price Per kg" : @"Avg Price Per lbs";
    avgPrice = [MGLineStyled lineWithLeft: label right:@"" size: rowSize];
    [avgPrice setFont: [ELA getFontThin:18]];
    avgPrice.onTap = ^{
        [me activateGraph:me.avgPrice];
    };
    [box.middleLines addObject:avgPrice];
    
    
    avgLossPerc = [MGLineStyled lineWithLeft: @"Average Estimated Loss" right:@"" size: rowSize];
    [avgLossPerc setFont: [ELA getFontThin:18]];
    avgLossPerc.onTap = ^{
        [me activateGraph:me.avgLossPerc];
    };
    [box.middleLines addObject:avgLossPerc];
    
    avgActualLossPerc = [MGLineStyled lineWithLeft: @"Average Actual Loss" right:@"" size: rowSize];
    [avgActualLossPerc setFont: [ELA getFontThin:18]];
    avgActualLossPerc.onTap = ^{
        [me activateGraph:me.avgActualLossPerc];
    };
    [box.middleLines addObject:avgActualLossPerc];
    
    
    avgServing = [MGLineStyled lineWithLeft: @"Average Serving Size" right:@"" size: rowSize];
    [avgServing setFont: [ELA getFontThin:18]];
    avgServing.onTap = ^{
        [me activateGraph:me.avgServing];
    };
    [box.middleLines addObject:avgServing];
    
    avgNetCostPerc = [MGLineStyled lineWithLeft: @"Average Food Cost" right:@"" size: rowSize];
    [avgNetCostPerc setFont: [ELA getFontThin:18]];
    avgNetCostPerc.onTap = ^{
        [me activateGraph:me.avgNetCostPerc];
    };
    [box.middleLines addObject:avgNetCostPerc];
    
    
    avgSalePrice = [MGLineStyled lineWithLeft: @"Average Sale Price" right:@"" size: rowSize];
    [avgSalePrice setFont: [ELA getFontThin:18]];
    avgSalePrice.onTap = ^{
        [me activateGraph:me.avgSalePrice];
    };
    [box.middleLines addObject:avgSalePrice];
    
    avgNetCost = [MGLineStyled lineWithLeft: @"Average Net Cost" right:@"" size: rowSize];
    [avgNetCost setFont: [ELA getFontThin:18]];
    avgNetCost.onTap = ^{
        [me activateGraph:me.avgNetCost];
    };
    [box.middleLines addObject:avgNetCost];
    
    [self.view addSubview:self.scroller];
    
    // setup the main scroller (using a grid layout)
    self.scroller.contentLayoutMode = MGLayoutGridStyle;
    //self.scroller.bottomPadding = 65;
    
    [self.scroller layout];
    
    
    
    /*
    chartView = [[LineChartView alloc] initWithFrame:graphBgRect];
    
    chartView.delegate = self;
    
    [chartView setViewPortOffsetsWithLeft:30.0f top:60.f right:30.f bottom:20.f];
    
    chartView.chartDescription.enabled = YES;
    chartView.chartDescription.textColor = [UIColor whiteColor];
    chartView.chartDescription.font = [ELA getFont:13];
    chartView.chartDescription.yOffset = -10;
    
    chartView.dragEnabled = YES;
    [chartView setScaleEnabled:YES];
    chartView.pinchZoomEnabled = NO;
    chartView.drawGridBackgroundEnabled = NO;
    chartView.maxHighlightDistance = 300.0;
    chartView.xAxis.enabled = NO;
    chartView.leftAxis.enabled = NO;
    chartView.rightAxis.enabled = NO;
    chartView.legend.enabled = NO;

    
    [chartView animateWithXAxisDuration:2.0 yAxisDuration:2.0];

    [self.view addSubview:chartView];
     
     */

    self.reportDays = 0;
    self.reportCut = @"all";
    
    
    [self updateAverages];
    [self activateGraph: avgPrice];
}

- (void)ScrollingTabController:(DKScrollingTabController*)controller selection:(NSUInteger)selection
{
    NSString *selectedId = cutIds[selection];
    
    self.reportCut = selectedId;
    
    [self updateAverages];
    [self updateGraph];
}

- (void)updateAverages
{
    float days = self.reportDays;
    NSString * objectObjectId = ([self.reportCut isEqualToString:@"all"]) ? nil : self.reportCut;
    PFObject* device = [ELA getUserDevice];
    NSString *deviceObjectId = (device == nil) ? nil : device.objectId;
    float value;
    NSString *sValue;
    
    value = [ELA getAveragePricePerWeight:days object:objectObjectId device:deviceObjectId];
    sValue = (value > 0) ? [ELA formatCurrency:value] : @"";
    avgPrice.rightItems = @[sValue].mutableCopy;

    
    value = [ELA getAverageLossPercentage:days object:objectObjectId device:deviceObjectId];
    sValue = (value > 0) ? [NSString stringWithFormat:@"%.1f%%", value] : @"";
    avgLossPerc.rightItems = @[sValue].mutableCopy;
    
    value = [ELA getAverageActualLossPercentage:days object:objectObjectId device:deviceObjectId];
    sValue = (value > 0) ? [NSString stringWithFormat:@"%.1f%%", value] : @"";
    avgActualLossPerc.rightItems = @[sValue].mutableCopy;
    

    value = [ELA getAverageServingSize:days object:objectObjectId device:deviceObjectId];
    sValue = @"";
    if (value > 0) {
        sValue = [NSString stringWithFormat:@"%.1f %@", value, [ELA isMetric] ? @"gm" : @"oz"];
    }
    avgServing.rightItems = @[sValue].mutableCopy;
        

    value = [ELA getAverageCostPercentage:days object:objectObjectId device:deviceObjectId];
    sValue = (value > 0) ? [NSString stringWithFormat:@"%.1f%%", value] : @"";
    avgNetCostPerc.rightItems = @[sValue].mutableCopy;
    
    value = [ELA getAverageSalePrice:days object:objectObjectId device:deviceObjectId];
    sValue = (value > 0) ? [ELA formatCurrency:value] : @"";
    avgSalePrice.rightItems = @[sValue].mutableCopy;
    
    value = [ELA getAverageNetServingCost:days object:objectObjectId device:deviceObjectId];
    sValue = (value > 0) ? [ELA formatCurrency:value] : @"";
    avgNetCost.rightItems = @[sValue].mutableCopy;
    
    [self.scroller layout];
}

- (void) updateGraph
{
    [self activateGraph:self.activeRow];
}

- (void) activateGraph: (MGLineStyled*)row
{
    self.activeRow = row;
    NSString * objectObjectId = ([self.reportCut isEqualToString:@"all"]) ? nil : self.reportCut;
    PFObject* device = [ELA getUserDevice];
    NSString *deviceObjectId = (device == nil) ? nil : device.objectId;
    
    UIColor *colorInactive = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.0f];
    UIColor *colorActive = [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f];
    
    [avgPrice setBackgroundColor: (avgPrice==row) ? colorActive : colorInactive];
    [avgLossPerc setBackgroundColor: (avgLossPerc==row) ? colorActive : colorInactive];
    [avgActualLossPerc setBackgroundColor: (avgActualLossPerc==row) ? colorActive : colorInactive];
    [avgServing setBackgroundColor: (avgServing==row) ? colorActive : colorInactive];
    [avgNetCostPerc setBackgroundColor: (avgNetCostPerc==row) ? colorActive : colorInactive];
    [avgSalePrice setBackgroundColor: (avgSalePrice==row) ? colorActive : colorInactive];
    [avgNetCost setBackgroundColor: (avgNetCost==row) ? colorActive : colorInactive];
    
    NSMutableArray *values;
    
    if (avgPrice==row) {
        values = [ELA getAveragePricePerWeightValues: self.reportDays object:objectObjectId device:deviceObjectId];
        [self updateChartData: @"Avg Price Per lbs" values:values];
    }
    else if (avgLossPerc==row) {
        values = [ELA getAverageLossPercentageValues: self.reportDays object:objectObjectId device:deviceObjectId];
        [self updateChartData: @"Avg Estimated Loss" values:values];
    }
    else if (avgActualLossPerc==row) {
        values = [ELA getAverageActualLossPercentageValues: self.reportDays object:objectObjectId device:deviceObjectId];
        [self updateChartData: @"Avg Actual Loss" values:values];
    }
    else if (avgServing==row) {
        values = [ELA getAverageServingSizeValues: self.reportDays object:objectObjectId device:deviceObjectId];
        [self updateChartData: @"Avg Serving Size" values:values];
    }
    else if (avgNetCostPerc==row) {
        values = [ELA getAverageCostPercentageValues: self.reportDays object:objectObjectId device:deviceObjectId];
        [self updateChartData: @"Avg Food Cost" values:values];
    }
    else if (avgSalePrice==row) {
        values = [ELA getAverageSalePriceValues: self.reportDays object:objectObjectId device:deviceObjectId];
        [self updateChartData: @"Avg Sale Price" values:values];
    }
    else if (avgNetCost==row) {
        values = [ELA getAverageNetServingCostValues: self.reportDays object:objectObjectId device:deviceObjectId];
        [self updateChartData: @"Avg Net Cost" values:values];
    }
    
    [self.scroller layout];
}


- (void)updateChartData: (NSString*)label values:(NSMutableArray*)values
{
    
    //LineChartDataSet *set1 = nil;
    
    int min = 0;
    int max = 0;
    float sum = 0;
    
    for (ChartDataEntry *entry in values) {
        sum += entry.y;
        if (entry.y < min) {
            min = floor(entry.y);
        }
        if (entry.y > max) {
            max = ceil(entry.y);
        }
    }
    float avg = sum / [values count];
    
    float perc = (avg - min) / (max - min);
    NSUInteger step = (NSUInteger)round(perc * (max - min));
    
    
    radialReport.progressTotal = (NSUInteger)(max - min);
    radialReport.progressCounter = step;
    
    /*
    set1 = [[LineChartDataSet alloc] initWithValues:values label:label];
    set1.mode = LineChartModeCubicBezier;
    set1.cubicIntensity = 0.1;
    set1.drawCirclesEnabled = YES;
    set1.lineWidth = 1.8;
    set1.circleRadius = 5.0;
    [set1 setCircleColor:UIColor.whiteColor];
    set1.highlightColor = [ELA getColorAccent];
    set1.highlightEnabled = YES;
    [set1 setColor:UIColor.whiteColor];
    set1.fillColor = UIColor.whiteColor;
    set1.fillAlpha = 1.f;
    set1.drawHorizontalHighlightIndicatorEnabled = YES;
    set1.valueTextColor = UIColor.whiteColor;
    set1.drawValuesEnabled  = YES;

    
    LineChartData *data = [[LineChartData alloc] initWithDataSet:set1];
    [data setValueFont:[ELA getFont:13]];
    [data setDrawValues:YES];
    
    [chartView setDescriptionText:label];
    chartView.xAxis.axisMinValue = min;
    chartView.xAxis.axisMaxValue = max;
    chartView.data = data;
*/
}


- (void)onSupport
{
    NSString * url = [ELA getConfigString:@"troubleshootUrl"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshData:^(BOOL success) {
        [self setTempActive];
    }];
}

- (void)onReportSegment:(UISegmentedControl *)segment
{
    NSInteger index = segment.selectedSegmentIndex;
    
    if (index == 0 || index == 1) {
        [scroller setHidden:YES];
        [graphBg setHidden:YES];
        [radialReport setHidden: YES];
        [radialLabelReport setHidden: YES];
        [tabController.view setHidden:YES];
        [timeSegments setHidden:YES];
        [headImage setHidden:NO];
        [radialTemp setHidden:NO];
        [radialLabelTemp setHidden:NO];
        [radialHumid setHidden:NO];
        [radialLabelHumid setHidden:NO];
        [graphLabel setHidden:NO];
        [lockerName setHidden:NO];
        [infoLabel setHidden:NO];
        [btnSupport setHidden:NO];
        
        if (index == 0) {
            [self scrollToTop];
            [self setTempActive];
        }
        else {
            [self scrollToTop];
            [self setHumidActive];
        }
    }
    else {
        [scroller setHidden:NO];
        [graphBg setHidden:NO];
        [radialReport setHidden: NO];
        [radialLabelReport setHidden: NO];
        [timeSegments setHidden:NO];
        [tabController.view setHidden:NO];
        [headImage setHidden:YES];
        [radialTemp setHidden:YES];
        [radialLabelTemp setHidden:YES];
        [radialHumid setHidden:YES];
        [radialLabelHumid setHidden:YES];
        [graphLabel setHidden:YES];
        [lockerName setHidden:NO];
        [infoLabel setHidden:YES];
        [btnSupport setHidden:YES];
        
        
        [self.view bringSubviewToFront:scroller];
        [self.view bringSubviewToFront:graphBg];
        //[self.view bringSubviewToFront:chartView];
        [self.view bringSubviewToFront:radialReport];
        [self.view bringSubviewToFront:radialLabelReport];
        [self.view bringSubviewToFront:lockerName];
        [self.view bringSubviewToFront:timeSegments];
        [self.view bringSubviewToFront:tabController.view];
    }
}

- (void)onTimeSegment:(UISegmentedControl *)segment
{
    NSInteger index = segment.selectedSegmentIndex;
    
    if (index == 0) {
        self.reportDays = 0;
    }
    else if (index == 1) {
        self.reportDays = 30;
    }
    else if (index == 2) {
        self.reportDays = 91;
    }
    else if (index == 3) {
        self.reportDays = 182;
    }
    else if (index == 4) {
        self.reportDays = 365;
    }
    
    [self updateAverages];
    [self updateGraph];
}

- (void)radialMeasurementSetup
{
    UIColor *colorTemp  = [ELA getColorTemp];
    UIColor *colorHumid = [ELA getColorHumid];
    UIColor *grey = [UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha: 0.95f];
    
    CGRect scrn = [ELA getScreen];
    int radialWidth = (int)(scrn.size.width - 100);
    int imgHeight = (int)(self.view.frame.size.height - segmentBg.frame.size.height);
    int radialTop   = (imgHeight - radialWidth) / 2.0f;

    CGRect blurRect = CGRectMake((scrn.size.width-radialWidth)/2, radialTop, radialWidth, radialWidth);
    UIImage *blurredImage = [ELA blurredSnapshot:headImage frame:blurRect];
    
    UIFont *fontRadialLabel = [UIFont systemFontOfSize:(int)(scrn.size.width / 16)];
    UIFont *fontValue = [ELA getFont: (int)(scrn.size.width / 6)];;
    
    radialTemp.progressTotal = (NSUInteger)(self.tempMax - self.tempMin);
    radialTemp.progressCounter = 0;
    radialTemp.label.shadowColor = [UIColor clearColor];
    radialTemp.label.textColor = [UIColor whiteColor];
    radialTemp.label.font = fontValue;
    radialTemp.theme.completedColor = colorTemp;
    radialTemp.theme.incompletedColor = colorHumid;
    radialTemp.theme.thickness = 15;
    radialTemp.theme.sliceDividerHidden = YES;
    radialTemp.theme.centerColor = [UIColor colorWithPatternImage:blurredImage];
    radialTemp.alpha = 0.0f;
    radialTemp.labelTextBlock = ^NSString * (MDRadialProgressView *progressView) {
        BOOL isUseF = [ELA isUseFahrenheit];
        
        NSString *scale = (isUseF) ? @"F" : @"C";
        float value = progressView.actualValue;
        if (isUseF) {
            value = [ELA celsiusToFahrenheit: value];
        }
        NSString *label = [NSString stringWithFormat: @"%.1f° %@", value, scale];
        return (progressView.progressCounter > 0) ? label : @"";
    };
    [self.view addSubview:radialTemp];
    radialTemp.progressCounter = 0;
    
    [radialLabelTemp setTextColor:[UIColor whiteColor]];
    [radialLabelTemp setFont: fontRadialLabel];
    [radialLabelTemp setText: @"Average"];
    [radialLabelTemp setTextAlignment:NSTextAlignmentCenter];
    [radialLabelTemp setAlpha: 0.0f];
    [self.view addSubview:radialLabelTemp];

    radialHumid.progressTotal = (NSUInteger)(self.humidMax - self.humidMin);
    radialHumid.progressCounter = 0;
    radialHumid.label.shadowColor = [UIColor clearColor];
    radialHumid.label.textColor = [UIColor whiteColor];
    radialHumid.label.font = fontValue;
    radialHumid.theme.completedColor = colorHumid;
    radialHumid.theme.incompletedColor = grey;
    radialHumid.theme.thickness = 15;
    radialHumid.theme.sliceDividerHidden = YES;
    radialHumid.theme.centerColor = [UIColor colorWithPatternImage:blurredImage];
    radialHumid.alpha = 0.0f;
    radialHumid.labelTextBlock = ^NSString * (MDRadialProgressView *progressView) {
        NSString *label = [NSString stringWithFormat: @"%.1f%%", progressView.actualValue];
        return (progressView.progressCounter > 0) ? label : @"";
    };
    [self.view addSubview:radialHumid];
    radialHumid.progressCounter = 0;
    
    [radialLabelHumid setTextColor:[UIColor whiteColor]];
    [radialLabelHumid setFont: fontRadialLabel];
    [radialLabelHumid setText: @"Average"];
    [radialLabelHumid setTextAlignment:NSTextAlignmentCenter];
    [radialLabelHumid setAlpha: 0.0f];
    [self.view addSubview:radialLabelHumid];
}

- (void)radialReportSetup
{
    UIColor *colorTemp  = [ELA getColorTemp];
    UIColor *grey = [UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha: 0.95f];
    
    CGRect scrn = [ELA getScreen];
    
    CGRect graphFrame = graphBg.frame;
    CGRect labelFrame = graphLabel.frame;
    int radialWidth = (int)(scrn.size.width / 2);
    int radialHeight = graphFrame.size.height - (labelFrame.origin.y+labelFrame.size.height) + graphFrame.origin.y;
    if (radialWidth > radialHeight) {
        radialWidth = radialHeight;
    }
    else if (radialWidth < radialHeight) {
        radialHeight = radialWidth;
    }

    
    int radialTop   = graphFrame.size.height - radialHeight + (graphFrame.origin.y / 2);
    
    CGRect blurRect = CGRectMake((scrn.size.width-radialWidth)/2, radialTop, radialWidth, radialHeight);
    [radialReport setFrame:blurRect];
    
    
    UIImage *blurredImage = [ELA blurredSnapshot:graphBg frame:blurRect];
    UIFont *fontValue = [ELA getFont: 18];
    
    
    __weak ReportsController *me = self;
    
    radialReport.progressTotal = 100;
    radialReport.progressCounter = 0;
    radialReport.label.shadowColor = [UIColor clearColor];
    radialReport.label.textColor = [UIColor whiteColor];
    radialReport.label.font = fontValue;
    radialReport.label.textAlignment = NSTextAlignmentCenter;
    radialReport.theme.completedColor = colorTemp;
    radialReport.theme.incompletedColor = grey;
    radialReport.theme.thickness = 15;
    radialReport.theme.sliceDividerHidden = YES;
    radialReport.theme.centerColor = [UIColor colorWithPatternImage:blurredImage];
    radialReport.alpha = 1.0f;
    radialReport.labelTextBlock = ^NSString * (MDRadialProgressView *progressView) {
        NSString *reportLabel = @"";
        NSString *value = @"";
        if (me.activeRow != nil) {
            if ([me.activeRow.leftItems count] > 0) {
              UILabel *label = (UILabel*)[me.activeRow.leftItems firstObject];
              reportLabel = [label text];
            }
            if ([me.activeRow.rightItems count] > 0) {
                UILabel *label = (UILabel*)[me.activeRow.rightItems firstObject];
                value = [label text];
            }
        }
        
        [me.radialLabelReport setText:reportLabel];
        
        return value;
        
    };
    [self.view addSubview:radialReport];
    
    
    NSString *radialLabel = @"";
    
    CGRect frameLabel = CGRectMake(0, blurRect.origin.y+(radialWidth/3.6f), scrn.size.width, 25);
    [radialLabelReport setFrame:frameLabel];
    [radialLabelReport setTextColor:[UIColor whiteColor]];
    [radialLabelReport setFont: [ELA getFont: 11]];
    [radialLabelReport setText: radialLabel];
    [radialLabelReport setTextAlignment:NSTextAlignmentCenter];
    [radialLabelReport setAlpha: 1.0f];
    //[radialLabelReport setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:radialLabelReport];
}


- (void)updateBlurredImage
{
    CGRect blurRect = CGRectMake(50, 20, 220, 220);
    UIImage *blurredImage = [ELA blurredSnapshot:headImage frame:blurRect];
    radialTemp.theme.centerColor = [UIColor colorWithPatternImage:blurredImage];
}




- (void)setCurrentTemp:(float)value
{
    if (self.hasData) {
        float perc = (value - self.tempMin) / (self.tempMax - self.tempMin);
        NSUInteger step = (NSUInteger)round(perc * (self.tempMax - self.tempMin));
        radialTemp.actualValue = value;
        radialTemp.progressCounter = step;
    }
    else {
        radialTemp.actualValue = 0;
        radialTemp.progressCounter = 0;
    }
}
- (void)setCurrentHumid:(float)value
{
    if (self.hasData) {
        float perc = (value - self.humidMin) / (self.humidMax - self.humidMin);
        NSUInteger step = (NSUInteger)round(perc * (self.humidMax - self.humidMin));
        radialHumid.actualValue = value;
        radialHumid.progressCounter = step;
    }
    else {
        radialHumid.actualValue = 0;
        radialHumid.progressCounter = 0;
    }
}

- (void)setRadialValue:(float)value
{
    float perc = (value - self.tempMin) / (self.tempMax - self.tempMin);
    NSUInteger step = (NSUInteger)round(perc * (self.tempMax - self.tempMin));
    radialReport.actualValue = value;
    radialReport.progressCounter = step;
    
}


- (void)setTempActive
{
    radialTemp.alpha = 1.0f;
    radialLabelTemp.alpha = 1.0f;
    radialHumid.alpha = 0.0f;
    radialLabelHumid.alpha = 0.0f;
    self.tempActive = true;
    
    CGRect scrn = [ELA getScreen];
    CGRect rect = infoLabel.frame;
    rect.origin.x = 15;
    rect.size.width = scrn.size.width - 30;
    [infoLabel setFrame:rect];
    
    
    if (self.hasData) {
        float value = radialTemp.actualValue;
        if (value < _warnTempMin) {
            [infoLabel setText:@"Your average temperature is low and we recommend you visit our support page."];
            [btnSupport setHidden:NO];
        }
        else if (value > _warnTempMax) {
            [infoLabel setText:@"Your average temperature is high and we recommend you visit our support page."];
            [btnSupport setHidden:NO];
        }
        else {
            if (self.lastSync == nil) {
                [infoLabel setText:@"Loading..."];
            }
            else {
                [infoLabel setText:@"Everything looks good!"];
            }
            [btnSupport setHidden:YES];
        }
    }
    else {
        if (self.lastSync == nil) {
            [infoLabel setText:@"Loading..."];
        }
        else {
            [infoLabel setText:@"Not enough data."];
        }
        
        [btnSupport setHidden:YES];
    }
    
    [infoLabel sizeToFit];
    rect = infoLabel.frame;
    rect.origin.x = (scrn.size.width - rect.size.width) / 2;
    [infoLabel setFrame:rect];
}
- (void)setHumidActive
{
    radialTemp.alpha = 0.0f;
    radialLabelTemp.alpha = 0.0f;
    radialHumid.alpha = 1.0f;
    radialLabelHumid.alpha = 1.0f;
    self.tempActive = false;
    
    if (self.hasData) {
        float value = radialHumid.actualValue;
        if (value < _warnHumidMin) {
            [infoLabel setText:@"Your average humidity is low and we recommend you visit our support page."];
            [btnSupport setHidden:NO];
        }
        else if (value > _warnHumidMax) {
            [infoLabel setText:@"Your average humidity is high and we recommend you visit our support page."];
            [btnSupport setHidden:NO];
        }
        else {
            if (self.lastSync == nil) {
                [infoLabel setText:@"Loading..."];
            }
            else {
                [infoLabel setText:@"Everything looks good!"];
            }
            [btnSupport setHidden:YES];
        }
    }
    else {
        if (self.lastSync == nil) {
            [infoLabel setText:@"Loading..."];
        }
        else {
            [infoLabel setText:@"Not enough data."];
        }
        [btnSupport setHidden:YES];
    }
    
    [infoLabel sizeToFit];
    CGRect scrn = [ELA getScreen];
    CGRect rect = infoLabel.frame;
    rect.origin.x = (scrn.size.width - rect.size.width) / 2;
    [infoLabel setFrame:rect];
}

- (void)handleScrollDown:(UITapGestureRecognizer *)recognizer
{
    /*
    CGPoint point = CGPointMake(arrowDown.frame.origin.x, arrowDown.frame.origin.y);
    
    CGRect frame = self.view.frame;
    
    UIScrollView *scroll = [self getScroll];
    CGSize scrollSize = scroll.contentSize;
    
    if ((point.y + frame.size.height) > scrollSize.height) {
        point.y = scrollSize.height - frame.size.height;
    }

    [scroll setContentOffset:point animated:YES];
     */
}


- (void)handleScrollUp:(UITapGestureRecognizer *)recognizer
{
    [self scrollToTop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction) onRefreshData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Refreshing Data...";
    
    [self refreshData: ^(BOOL success) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)refreshData:(void (^)(BOOL))callback
{
    PFObject *device = [ELA getUserDevice];
    NSString *impeeId = [device objectForKey:@"impeeId"];
    [PFCloud callFunctionInBackground:@"getAveragesByImpeeId"
                       withParameters:@{@"impeeId": impeeId}
                                block:^(NSDictionary* dict, NSError *error) {
                                    BOOL success = (error == nil && [dict count] > 0);
                                    self.lastSync = [NSDate date];
                                    if (success) {
                                        self.hasData = YES;
                                        self.tempAvg = [[dict objectForKey:@"temperatureAvg"] floatValue];
                                        self.humidAvg = [[dict objectForKey:@"humidityAvg"] floatValue];
                                    }
                                    else {
                                        self.tempAvg =  0;
                                        self.humidAvg = 0;
                                    }
                                    [self setCurrentTemp: self.tempAvg];
                                    [self setCurrentHumid: self.humidAvg];
                                    [self onReportSegment: reportSegments];
                                    if (callback) {
                                        callback(success);
                                    }
                                }];
}



- (void) showImage: (UIImageView*)image show: (BOOL)show
{

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25f];
    

    if (show) {
        image.alpha = 1.0f;
    }
    else {
        image.alpha = 0.0f;
    }
    
    [UIView commitAnimations];
}

- (IBAction)onMenu: (id)sender
{
    self.theMenu.activeItemName = @"Reports";
    if (self.theMenu.showing) {
        [self.theMenu hideMenu];
        [self.theMenu setAlpha:0.0f];
        [self.view sendSubviewToBack:self.theMenu];
    }
    else {
        /*
        UIScrollView * scrollView = [self getScroll];
        CGPoint offset = scrollView.contentOffset;
        [scrollView setContentOffset:offset animated:NO];
         */

        //CGRect frame = self.theMenu.frame;
        //frame.origin.y = offset.y + 0;//[self getHeaderHeight];
        //self.theMenu.frame = frame;
        
        [self.view bringSubviewToFront:self.theMenu];
        [self.theMenu setAlpha:1.0f];
        [self.theMenu showMenu];
    }
}


@end
