//
//  DashboardController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import "DashboardController.h"
#import <Parse/Parse.h>
#import "DropdownController.h"
#import "ELA.h"
#import "ItemController.h"
#import "SVPullToRefresh.h"
#import "ObjectController.h"

@interface DashboardController ()


- (int)getHeaderHeight;
- (void)scrollToTop;


@end

@implementation DashboardController

@synthesize impeeId;
@synthesize lockerName;
@synthesize lastUpdated;
@synthesize notConnectedBanner;
@synthesize headImage;
@synthesize headLogo;
@synthesize radialTemp;
@synthesize radialLabelTemp;
@synthesize radialHumid;
@synthesize radialLabelHumid;
@synthesize viewTemp;
@synthesize viewHumid;
@synthesize headAgingType;
@synthesize warningLabel;
@synthesize helpButton;

NSArray * _Nullable deleteItems=nil;

- (UIScrollView*)getScroll
{
    return (UIScrollView*)self.view;
}
- (int)getHeaderHeight
{
    return self.navigationController.navigationBar.frame.size.height + [ELA getStatusBarHeight];
}
- (void)scrollToTop
{
    CGPoint point = CGPointMake(headImage.frame.origin.x, headImage.frame.origin.y);
    //point.y -= [self getHeaderHeight];
    [[self getScroll] setContentOffset:point animated:YES];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	[self.view bringSubviewToFront:headLogo];
	[self.view bringSubviewToFront:headAgingType];
	[self.view bringSubviewToFront:lockerName];
	[self.view bringSubviewToFront:lastUpdated];
	[self.view bringSubviewToFront:radialTemp];
	[self.view bringSubviewToFront:radialLabelTemp];
	[self.view bringSubviewToFront:radialHumid];
	[self.view bringSubviewToFront:radialLabelHumid];
	[self.view bringSubviewToFront:notConnectedBanner];
	
    [self updateLastUpdatedText];
}

- (void)updateLastUpdatedText
{
    NSString *lastUpdatedDate = [ELA getLastUpdated];
    if (lastUpdatedDate != nil) {
        lastUpdated.text = [NSString stringWithFormat: @"Last updated %@", lastUpdatedDate];
    }
    else {
        lastUpdated.text = [NSString stringWithFormat: @"Hang tight, first readings on the way."];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Customize your menubar programmatically here.

    self.tempMin = 0.0f;
    self.tempMax = 35.0f;
    self.humidMin = 0;
    self.humidMax = 100.0f;

    self.tempActive = true;
    
    [[self getScroll] setDelegate:self];
    
    UIColor *colorTemp = [ELA getColorTemp];
    UIColor *colorHumid = [ELA getColorHumid];
	
    CGRect scrn = [ELA getScreen];
    
    [self.view setBackgroundColor: [ELA getColorBGLight]];
    
    int headHeight = (int)(scrn.size.width / (1242.0f/1400.0f));
    
    NSString *sImage = [ELA isProUser] ? @"BGDashboardPro" : @"BGDashboard";
    
    headImage = [ELA addImage:sImage X:0 Y:0 W:scrn.size.width H:headHeight];
    [headImage setClipsToBounds:YES];
    [headImage setContentMode:UIViewContentModeScaleAspectFill];
    
    [self.view addSubview:headImage];
    [self.view sendSubviewToBack:headImage];
    
    int radialWidth = (int)(scrn.size.width - 100);
    int radialTop   = (headHeight - radialWidth) / 2.0f;
	
    lockerName = [[UILabel alloc] initWithFrame:CGRectMake(0, radialTop-55, scrn.size.width, 20)];
    [lockerName setText:@""];
    [lockerName setTextAlignment:NSTextAlignmentCenter];
    [lockerName setTextColor:[UIColor whiteColor]];
    [lockerName setFont: [ELA getFont:18]];
    [self.view addSubview:lockerName];
	 
	lastUpdated = [[UILabel alloc] initWithFrame:CGRectMake(0, radialTop-35, scrn.size.width, 20)];
	[lastUpdated setText: [ELA getLastUpdated]];
	[lastUpdated setTextAlignment:NSTextAlignmentCenter];
	[lastUpdated setTextColor:[UIColor whiteColor]];
	[lastUpdated setFont: [ELA getFont:12]];
	[self.view addSubview:lastUpdated];
	
	notConnectedBanner = [[UIView alloc]initWithFrame:CGRectMake(0, 0, scrn.size.width, 50)];
	notConnectedBanner.backgroundColor = [UIColor clearColor];
	UIView * background = [[UIView alloc]initWithFrame:CGRectMake(0, 0, scrn.size.width, 50)];
	background.alpha = 0.6;
	background.backgroundColor = [UIColor redColor];
	[notConnectedBanner addSubview:background];
	
	UIImageView * icon = [ELA addImage:@"WarningIcon" frame:CGRectMake(20, (notConnectedBanner.frame.size.height /2) - 10, 20, 20)];
	[notConnectedBanner addSubview:icon];
	
	CGFloat width = scrn.size.width * 0.6;
	warningLabel = [[UILabel alloc] initWithFrame:CGRectMake((scrn.size.width/2) - (width / 2), 0, width, notConnectedBanner.frame.size.height)];
	warningLabel.text = @"Steak Locker Not Connected";
	warningLabel.textAlignment = NSTextAlignmentLeft;
	warningLabel.textColor = [UIColor whiteColor];
	warningLabel.font = [ELA getFont:12];
	[notConnectedBanner addSubview:warningLabel];
	
	CGFloat buttonX = CGRectGetMaxX(warningLabel.frame);
	helpButton = [[UIButton alloc]initWithFrame: CGRectMake( buttonX, 0, scrn.size.width - buttonX,notConnectedBanner.frame.size.height)];
	[helpButton setTitle:@"Get Help" forState:UIControlStateNormal];
	[helpButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
	helpButton.titleLabel.font = [ELA getFontBold:12];
	[helpButton addTarget:self action:@selector(onGetHelp:) forControlEvents:UIControlEventTouchUpInside];
	
	[notConnectedBanner addSubview:helpButton];
	notConnectedBanner.alpha = 0.0f;
	
	[self.view addSubview: notConnectedBanner];
	
    CGRect radialFrame = CGRectMake((scrn.size.width-radialWidth)/2, radialTop, radialWidth, radialWidth);
    radialTemp = [[MDRadialProgressView alloc] initWithFrame:radialFrame];
    radialLabelTemp = [[UILabel alloc] initWithFrame:CGRectMake(0, radialFrame.origin.y+(radialWidth/3.6f), scrn.size.width, 25)];
    radialHumid = [[MDRadialProgressView alloc] initWithFrame:radialFrame];
    radialLabelHumid = [[UILabel alloc] initWithFrame:CGRectMake(0, radialFrame.origin.y+(radialWidth/3.6f), scrn.size.width, 25)];
    

    [self radialMeasurementSetup];
    [self setTempActive];
    
    headLogo = [ELA addImage: @"LoginHeaderLogo" X:0 Y:headHeight-40.0f W:160 H:30];
    [self.view addSubview:headLogo];
    
    
    CGRect agingRect = CGRectMake(scrn.size.width/2.0f, headHeight-40.0f, scrn.size.width/2.0f-20.0f, 30.0f);
    headAgingType = [[UILabel alloc] initWithFrame:agingRect];
    
    headAgingType.font = [ELA getFontThin: 16];
    headAgingType.textColor = [UIColor whiteColor];
    headAgingType.textAlignment = NSTextAlignmentRight;
    headAgingType.text = [ELA getAgingType];
    [self.view addSubview:headAgingType];
    
    
    int offset = headHeight;
    

    CGRect frame = CGRectMake(0, offset+0, scrn.size.width, 80);
    viewTemp = [[MeasurementProgressView alloc] initWithFrame:frame title:@"Temperature" color:colorTemp];
    [self.view addSubview:viewTemp];
    [viewTemp setLimits: self.tempMin max:self.tempMax];
    
    frame.origin.y += frame.size.height;
    viewHumid = [[MeasurementProgressView alloc] initWithFrame:frame title:@"Humidity" color:colorHumid];
    [self.view addSubview:viewHumid];
    [viewHumid setLimits:self.humidMin max:self.humidMax];
    
    
    UITapGestureRecognizer *tapperTemp;
    tapperTemp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [viewTemp addGestureRecognizer:tapperTemp];

    UITapGestureRecognizer *tapperHumid;
    tapperHumid = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [viewHumid addGestureRecognizer:tapperHumid];

    frame.origin.y += frame.size.height;
    frame.size.height = 40;
    
    [self updateScrollHeight];
    
    
    PFObject *device = [ELA getUserDevice];
    if (device != nil) {
        [lockerName setText: (NSString*)[device objectForKey:@"nickname"]];
    }
    
    [self refreshData:^(BOOL success) {
        [self setTempActive];
    }];
    
    [[self getScroll] addPullToRefreshWithActionHandler:^{
        UIScrollView *scrollView = [self getScroll];
        
        [self refreshData:^(BOOL success) {
            [scrollView.pullToRefreshView stopAnimating];
        }];
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(updateData:) userInfo:nil repeats:true];
}

- (void)radialMeasurementSetup
{
    UIColor *colorTemp = [ELA getColorTemp];
    UIColor *colorHumid = [ELA getColorHumid];
    UIColor *grey = [UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha: 0.95f];
    CGRect scrn = [ELA getScreen];
    
    int radialWidth = (int)(scrn.size.width - 100);
    int headHeight = (int)(scrn.size.width / (1242.0f/1400.0f));
    int radialTop   = (headHeight - radialWidth) / 2.0f;
    
    
    CGRect blurRect = CGRectMake((scrn.size.width-radialWidth)/2, radialTop, radialWidth, radialWidth);
    UIImage *blurredImage = [ELA blurredSnapshot:headImage frame:blurRect];
    
    UIFont *fontRadialLabel = [UIFont systemFontOfSize:(int)(scrn.size.width / 16)];
    UIFont *fontValue = [ELA getFont: (int)(scrn.size.width / 6)];;
    radialTemp.labelTextBlock = ^NSString * (MDRadialProgressView *progressView) {
        BOOL isUseF = [ELA isUseFahrenheit];
        NSString *label;
        NSString *scale = (isUseF) ? @"F" : @"C";
        float value = progressView.actualValue;
        if (value > 0) {
            if (isUseF) {
                value = [ELA celsiusToFahrenheit: value];
            }
            label = [NSString stringWithFormat: @"%.1f° %@", value, scale];
        }
        else {
            label = @"-";
        }
        return label;
    };
    radialTemp.progressTotal = (NSUInteger)(self.tempMax - self.tempMin);
    radialTemp.progressCounter = 0;
    radialTemp.actualValue = 0;
    radialTemp.label.shadowColor = [UIColor clearColor];
    radialTemp.label.textColor = [UIColor whiteColor];
    radialTemp.label.font = fontValue;
    radialTemp.theme.completedColor = colorTemp;
    radialTemp.theme.incompletedColor = grey;
    radialTemp.theme.thickness = 15;
    radialTemp.theme.sliceDividerHidden = YES;
    radialTemp.theme.centerColor = [UIColor colorWithPatternImage:blurredImage];
    radialTemp.alpha = 0.0f;

    [self.view addSubview:radialTemp];
    
    [radialLabelTemp setTextColor:[UIColor whiteColor]];
    [radialLabelTemp setFont: fontRadialLabel];
    [radialLabelTemp setText: @"Temperature"];
    [radialLabelTemp setTextAlignment:NSTextAlignmentCenter];
    [radialLabelTemp setAlpha: 0.0f];
    [self.view addSubview:radialLabelTemp];
    
    
    radialHumid.labelTextBlock = ^NSString * (MDRadialProgressView *progressView) {
        NSString *label;
        if (progressView.actualValue > 0) {
            label = [NSString stringWithFormat: @"%.1f%%", progressView.actualValue];
        }
        else {
            label = @"-";
        }
        return label;
    };
    radialHumid.progressTotal = (NSUInteger)(self.humidMax - self.humidMin);
    radialHumid.progressCounter = 0;
    radialHumid.actualValue = 0;
    radialHumid.label.shadowColor = [UIColor clearColor];
    radialHumid.label.textColor = [UIColor whiteColor];
    radialHumid.label.font = fontValue;
    radialHumid.theme.completedColor = colorHumid;
    radialHumid.theme.incompletedColor = grey;
    radialHumid.theme.thickness = 15;
    radialHumid.theme.sliceDividerHidden = YES;
    radialHumid.theme.centerColor = [UIColor colorWithPatternImage:blurredImage];
    radialHumid.alpha = 0.0f;

    [self.view addSubview:radialHumid];
    
    [radialLabelHumid setTextColor:[UIColor whiteColor]];
    [radialLabelHumid setFont: fontRadialLabel];
    [radialLabelHumid setText: @"Humidity"];
    [radialLabelHumid setTextAlignment:NSTextAlignmentCenter];
    [radialLabelHumid setAlpha: 0.0f];
    [self.view addSubview:radialLabelHumid];
    

}

- (void)updateBlurredImage
{
    CGRect blurRect = CGRectMake(50, 20, 220, 220);
    UIImage *blurredImage = [ELA blurredSnapshot:headImage frame:blurRect];
    radialTemp.theme.centerColor = [UIColor colorWithPatternImage:blurredImage];
}

- (void)setCurrentTemp:(float)value
{
    float perc = (value - self.tempMin) / (self.tempMax - self.tempMin);
    NSUInteger step = (NSUInteger)round(perc * (self.tempMax - self.tempMin));
    radialTemp.actualValue = value;
    radialTemp.progressCounter = step;
    
    [viewTemp setProgress: value];
}
- (void)setCurrentHumid:(float)value
{
    float perc = (value - self.humidMin) / (self.humidMax - self.humidMin);
    NSUInteger step = (NSUInteger)round(perc * (self.humidMax - self.humidMin));
    radialHumid.actualValue = value;
    radialHumid.progressCounter = step;
    [viewHumid setProgress:value];
}


- (void)setTempActive
{
    [viewTemp setViewActive:YES];
    radialTemp.alpha = 1.0f;
    radialLabelTemp.alpha = 1.0f;
    [viewHumid setViewActive:NO];
    radialHumid.alpha = 0.0f;
    radialLabelHumid.alpha = 0.0f;
    self.tempActive = true;
}
- (void)setHumidActive
{
    [viewTemp setViewActive:NO];
    radialTemp.alpha = 0.0f;
    radialLabelTemp.alpha = 0.0f;
    [viewHumid setViewActive:YES];
    radialHumid.alpha = 1.0f;
    radialLabelHumid.alpha = 1.0f;
    self.tempActive = false;
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

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    BOOL bShowConnectionWarning = [ELA showConnectionWarning];
    BOOL bShowTempWarning = [ELA showTempWarning];
    BOOL bShowHumWarning = [ELA showHumidityWarning];
    UIView *tappedView = [recognizer.view hitTest:[recognizer locationInView:recognizer.view] withEvent:nil];
    if (tappedView == viewTemp || [tappedView superview] == viewTemp) {
        [self scrollToTop];
        [self setTempActive];
        if (bShowTempWarning) {
            self.notConnectedBanner.alpha = 1.0f;
            self.warningLabel.text = @"Your temperature is too high.";
            [self.helpButton setHidden:true];
        }
        else if (bShowConnectionWarning) {
            self.notConnectedBanner.alpha = 1.0f;
            self.warningLabel.text = @"Steak Locker Not Connected";
            [self.helpButton setHidden:false];
        }
        else {
            self.notConnectedBanner.alpha = 0.0f;
        }
    }
    else if (tappedView == viewHumid || [tappedView superview] == viewHumid) {
        [self scrollToTop];
        [self setHumidActive];
        if (bShowHumWarning) {
            self.notConnectedBanner.alpha = 1.0f;
            self.warningLabel.text = @"Your humidity is too low.";
            [self.helpButton setHidden:true];
        }
        else if (bShowConnectionWarning) {
            self.notConnectedBanner.alpha = 1.0f;
            self.warningLabel.text = @"Steak Locker Not Connected";
            [self.helpButton setHidden:false];
        }
        else {
            self.notConnectedBanner.alpha = 0.0f;
        }
    }
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

- (void) onGetHelp: (id) sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ela-lifestyle.com/help/getting-started"]];
	
}

- (IBAction)onLogout
{
    UIStoryboard *sb = nil;
    UIViewController *vc = nil;
    
    [PFUser logOut];
    
    sb = [UIStoryboard storyboardWithName:@"Auth" bundle:nil];
    vc = [sb instantiateInitialViewController];
    
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)updateData:(NSTimer *)timer {
    [self refreshData:nil];
}

- (void)refreshData:(void (^)(BOOL))callback
{
    NSLog(@"refresh called");
    PFObject *device = [ELA getUserDevice];
   
    if (device == nil) {
        callback(NO);
    }
    
    // The device contains the last temp and humidity, so update here
    NSNumber *value = [device objectForKey:@"lastTemperature"];
    if (value != nil && [value floatValue] > 0) {
        [self setCurrentTemp:[value floatValue]];
    }
    value = [device objectForKey:@"lastHumidity"];
    if (value != nil && [value floatValue] > 0) {
        [self setCurrentHumid:[value floatValue]];
    }
    
    
    // But then grab from the server just in case.
    impeeId = [device objectForKey:@"impeeId"];
	[ELA getLatestMeasurement:impeeId callback:^(BOOL success, PFObject *measurement) {
		if (success) {
            // This measurement should be the same as or more up to date than the one that the "device" object
            // has stored in memory.
            // Update the device in memory, so that the error message may go away
            [ELA updateUserDevice: device latestMeasurement:measurement];
            [self updateLastUpdatedText];
            
			[self setCurrentTemp:[measurement[@"temperature"] floatValue]];
			[self setCurrentHumid:[measurement[@"humidity"] floatValue]];
		}
		if (callback) {
			callback(success);
		}
		
		[UIView animateWithDuration:0.2 animations:^{
            BOOL bShowConnectionWarning = [ELA showConnectionWarning];
            BOOL bShowTempWarning = [ELA showTempWarning];
            BOOL bShowHumWarning = [ELA showHumidityWarning];
            
			if (bShowConnectionWarning) {
				self.notConnectedBanner.alpha = 1.0f;
                self.warningLabel.text = @"Steak Locker Not Connected";
                [self.helpButton setHidden:false];
			}
            else if (bShowTempWarning) {
                self.notConnectedBanner.alpha = 1.0f;
                self.warningLabel.text = @"Your temperature is too high.";
                [self.helpButton setHidden:true];
            }
            else if (bShowHumWarning) {
                self.notConnectedBanner.alpha = 1.0f;
                self.warningLabel.text = @"Your humidity is too low.";
                [self.helpButton setHidden:true];
            }
			else {
				self.notConnectedBanner.alpha = 0.0f;
			}
		}];
	}];
}

- (void)updateScrollHeight
{
    CGRect frame = viewHumid.frame;
//    int height = frame.origin.y + frame.size.height;

    /*
    CGRect frameBlog = self.blogScroller.frame;
    frameBlog.origin.y = height;
    self.blogScroller.frame = frameBlog;
     */
    
    //height += frameBlog.size.height;
    //height += arrowUp.frame.size.height + 20;
    
    
    CGRect scrn = [ELA getScreen];
    float headerHeight = [ELA getHeaderHeight:self];
    UIScrollView *scroll = [self getScroll];
    [scroll setContentSize: CGSizeMake(scrn.size.width, scrn.size.height - headerHeight + 1)];
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
    self.theMenu.activeItemName = @"Dashboard";
    if (self.theMenu.showing) {
        [self.theMenu hideMenu];
        [self.theMenu setAlpha:0.0f];
        [self.view sendSubviewToBack:self.theMenu];
    }
    else {
        UIScrollView * scrollView = [self getScroll];
        CGPoint offset = scrollView.contentOffset;
        [scrollView setContentOffset:offset animated:NO];

        CGRect frame = self.theMenu.frame;
        frame.origin.y = offset.y + 0;//[self getHeaderHeight];
        self.theMenu.frame = frame;
        
        [self.view bringSubviewToFront:self.theMenu];
        [self.theMenu setAlpha:1.0f];
        [self.theMenu showMenu];
    }
}


- (IBAction)onAdd: (id)sender
{
    [self.theMenu hideMenu];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Object" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"Object"];
    [self presentViewController:vc animated:YES completion:nil];
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController*)vc;
        ObjectController *oc = (ObjectController*)[nc.viewControllers objectAtIndex:0];
        oc.isRemoving = NO;
        oc.isAdding = YES;
        oc.parent = self;
        [oc reloadForm];
    }
}

@end
