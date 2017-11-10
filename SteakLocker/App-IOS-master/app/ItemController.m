//
//  ViewController.h
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import "ItemController.h"
#import "ObjectController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ItemController ()
-(void)setupDay;
-(void)setupNutrition;
-(void)setupInfo;

@end

@implementation ItemController
@synthesize userObject;
@synthesize image;
@synthesize labelNickname;
@synthesize tabDay;
@synthesize tabNutrition;
@synthesize tabInfo;
@synthesize pageDay;
@synthesize pageNutrition;
@synthesize pageInfo;
@synthesize radialDays;
@synthesize btnRemove;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UITapGestureRecognizer *tapDay;
    UITapGestureRecognizer *tapNutrition;
    UITapGestureRecognizer *tapInfo;
    CGRect frame;
    NSString *title;
    NSString *suffix;
    
    Object *object = userObject.object;
    CGRect scrn = [ELA getScreen];
    CGRect rect = self.view.frame;
    

    image = [[UIImageView alloc] init];
    if (object != nil && object.imageUrl != nil) {
        UIImage* placeholder = [UIImage imageNamed:@"UserObjectDefault"];
        [image sd_setImageWithURL: [NSURL URLWithString: object.imageUrl] placeholderImage:placeholder];
    }
    else {
        image.image = [UIImage imageNamed:@"UserObjectDefault"]; // placeholder image
    }
    
    int headerHeight = [ELA getHeaderHeight:self];
    int imageHeight = (int)(scrn.size.width / 1.77f);
    
    image.frame = CGRectMake(0, 0, scrn.size.width, imageHeight);
    image.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview: image];

    
    if (![ELA isEmpty:userObject.nickname]) {
        labelNickname = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, scrn.size.width, 30)];
        labelNickname.backgroundColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.7f];
        labelNickname.textColor = [ELA getColorText];
        labelNickname.font = [ELA getFont:16];
        labelNickname.text = userObject.nickname;
        labelNickname.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:labelNickname];
    }
    
    int buttonY =  imageHeight;
    
    frame = CGRectMake(0, buttonY, scrn.size.width / 3, 80);
    
    
    if ([userObject isInLocker]) {
        title = [NSString stringWithFormat:@"%d", [userObject getCurrentDay]];
        suffix = [userObject getDaysLeftString];
        tabDay = [[ObjectTabView alloc] initWithFrame:frame prefix:@"Day" title:title suffix:suffix active:true];
        tapDay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapDay:)];
        [tabDay addGestureRecognizer:tapDay];
        [self.view addSubview: tabDay];
    }
    else {
        title = [NSString stringWithFormat:@"%d", [userObject getDaysAged]];
        tabDay = [[ObjectTabView alloc] initWithFrame:frame prefix:@"Aged" title:title suffix:@"Days" active:true];
        tapDay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapDay:)];
        [tabDay addGestureRecognizer:tapDay];
        [self.view addSubview: tabDay];
    }
    
    

    frame = CGRectMake(scrn.size.width / 3, buttonY, scrn.size.width / 3, 80);
    
    NSString *nutTitle = (object == nil || [ELA isEmpty:object.calories]) ? @"?" : object.calories;
    tabNutrition = [[ObjectTabView alloc] initWithFrame:frame prefix:@"Nutrition" title:nutTitle suffix:@"per serving" active:false];
    tapNutrition = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapNutrition:)];
    [tabNutrition addGestureRecognizer:tapNutrition];
    [self.view addSubview: tabNutrition];
    
    
    frame = CGRectMake(scrn.size.width - (scrn.size.width / 3), buttonY, scrn.size.width / 3, 80);
    tabInfo = [[ObjectTabView alloc] initWithFrame:frame prefix:@"Information" icon:@"IconInfo" suffix:@"Learn more" active: false];
    tapInfo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapInfo:)];
    [tabInfo addGestureRecognizer:tapInfo];
    [self.view addSubview: tabInfo];
    
    
    
    int pageY = buttonY+frame.size.height;
    frame = CGRectMake(0, pageY, scrn.size.width, rect.size.height - pageY - headerHeight);
    pageDay = [[UIScrollView alloc] initWithFrame:frame];
    [self.view addSubview:pageDay];
    
    pageNutrition = [[UIScrollView alloc] initWithFrame:frame];
    pageNutrition.frame = frame;
    pageNutrition.hidden = true;
    [self.view addSubview:pageNutrition];
    
    pageInfo = [[UIWebView alloc] initWithFrame:frame];
    pageInfo.hidden = true;
    pageInfo.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.view addSubview:pageInfo];
    
    [self setupDay];
    [self setupNutrition];
    [self setupInfo];
}



-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    Object *object = userObject.object;
    self.navigationController.navigationBar.topItem.title = (object != nil) ? object.title : @"Custom";
    

    
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Edit"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(onEdit)];
    self.navigationItem.rightBarButtonItem = flipButton;

    
    [tabDay setViewActive:YES];
}

- (void)onEdit
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Object" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"Object"];
    [self presentViewController:vc animated:YES completion:nil];
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController*)vc;
        ObjectController *oc = (ObjectController*)[nc.viewControllers objectAtIndex:0];
        oc.parent = self;
        oc.isRemoving = NO;
        oc.isAdding = NO;
        [oc setCurrentUserObject:self.userObject];
    }
}

- (void)onRemove
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Object" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"Object"];
    [self presentViewController:vc animated:YES completion:nil];
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController*)vc;
        ObjectController *oc = (ObjectController*)[nc.viewControllers objectAtIndex:0];
        oc.parent = self;
        oc.isRemoving = YES;
        [oc setCurrentUserObject:self.userObject];
    }
}

- (void)setupDay
{
    CGRect scrn = [[UIScreen mainScreen] bounds];
    CGRect frame;

    if (radialDays != nil) {
        [radialDays removeFromSuperview];
    }
    if (self.labelDaysAged != nil) {
        [self.labelDaysAged removeFromSuperview];
    }
    if (btnRemove != nil) {
        [btnRemove removeFromSuperview];
    }
    
    
    if ([userObject isInLocker]) {
        float width = (scrn.size.width-40) / 2;
        frame = CGRectMake((scrn.size.width-width)/2, 20, width, width);
        
        radialDays = [[MDRadialProgressView alloc] initWithFrame:frame];
        radialDays.progressTotal = [userObject getTotalDays];
        radialDays.progressCounter = [userObject getCurrentDay];
        radialDays.label.shadowColor = [UIColor clearColor];
        radialDays.label.textColor = [ELA getColorText];
        radialDays.label.font = [ELA getFontThin:15];
        radialDays.label.text = [userObject getDaysLeftString];
        radialDays.theme.completedColor = [ELA getColorAccent];
        radialDays.theme.incompletedColor = [ELA getColorBGDark];
        radialDays.theme.thickness = 35;
        radialDays.theme.sliceDividerHidden = NO;
        radialDays.theme.sliceDividerColor = [ELA getColorBGLight];
        radialDays.theme.sliceDividerThickness = 2.0f;
    //    radialDays.theme.centerColor = [UIColor colorWithPatternImage:blurredImage];
        radialDays.alpha = 1.0f;
        [self.pageDay addSubview:radialDays];
        
        btnRemove = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnRemove setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        UIImage *bg = [ELA imageWithColor: [ELA getColorAccent]];
        [btnRemove setBackgroundImage:bg forState:UIControlStateNormal];
        
        UIColor *color = [UIColor colorWithRed: 153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        UIImage *bgOff = [ELA imageWithColor: color];
        [btnRemove setBackgroundImage:bgOff forState:UIControlStateDisabled];
        
        [btnRemove setTitle:@"Remove and Calculate Yield" forState: UIControlStateNormal];
        
        CGRect frameB = CGRectMake(25, width+50, scrn.size.width-50, 60);
        [btnRemove setFrame: frameB];
        [btnRemove addTarget:self action:@selector(onRemove) forControlEvents:UIControlEventTouchUpInside];
        [pageDay addSubview: btnRemove];
        
        [btnRemove setClipsToBounds:YES];
        btnRemove.layer.cornerRadius = 30;
        btnRemove.layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.0f].CGColor;
    }
    else {
        CGRect frameL2 = CGRectMake(20, 20, (scrn.size.width-40), (pageDay.frame.size.height-40));
        self.labelDaysAged = [[UILabel alloc] init];
        [self.labelDaysAged setFrame:frameL2];
        [self.labelDaysAged setNumberOfLines:0];
        
        [self.pageDay addSubview:self.labelDaysAged];
        [self updateDayInfo];

    }
}



- (void)updateDayInfo
{
    NSDate *startDate = [userObject getStartDate];
    NSDate *endDate = (userObject.removedAt != nil) ? userObject.removedAt : userObject.finishedAt;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *str = [NSString stringWithFormat:@"Aged from %@ to %@", [dateFormat stringFromDate:startDate], [dateFormat stringFromDate:endDate]];
    [self.labelDaysAged setText:str];
}

- (void)setupNutrition
{
    NutritionViewController *nut = [[NutritionViewController alloc] initWithObject:userObject.object];

    [nut willMoveToParentViewController: self];
    CGRect frame = nut.view.frame;
    frame.size.height = pageNutrition.frame.size.height;
    nut.view.frame = frame;
    
    [self.pageNutrition addSubview:nut.view];
    [self addChildViewController:nut];
    [nut didMoveToParentViewController:self];
}

- (void) setupInfo
{
    Object *object = userObject.object;
    NSString *format = @"<html><head> \
    <style type=\"text/css\">\
        body{background:#efefef;padding:20px;} \
        *{font-family:'Helvetica Neue';font-weight:200;} \
    </style> \
    </head> \
    <body>%@</body> \
    </html>";
    
    NSString *info = nil;
    if (object.information) {
        info = object.information;
    }
    else {
        info = @"Information is not available at this time.";
    }
    
    [pageInfo loadHTMLString:[NSString stringWithFormat:format, info] baseURL:nil];    
}


- (void)handleTapDay:(UITapGestureRecognizer *)recognizer
{
    [tabDay setViewActive:YES];
    [tabNutrition setViewActive:NO];
    [tabInfo setViewActive:NO];
    [pageDay setHidden:NO];
    [pageNutrition setHidden:YES];
    [pageInfo setHidden:YES];
}

- (void)handleTapNutrition:(UITapGestureRecognizer *)recognizer
{
    [tabDay setViewActive:NO];
    [tabNutrition setViewActive:YES];
    [tabInfo setViewActive:NO];
    [pageDay setHidden:YES];
    [pageNutrition setHidden:NO];
    [pageInfo setHidden:YES];
    }

- (void)handleTapInfo:(UITapGestureRecognizer *)recognizer
{
    [tabDay setViewActive:NO];
    [tabNutrition setViewActive:NO];
    [tabInfo setViewActive:YES];
    [pageDay setHidden:YES];
    [pageNutrition setHidden:YES];
    [pageInfo setHidden:NO];
}


- (void) updateDayTab
{
    NSString *title;
    NSString *suffix;
    if ([userObject isInLocker]) {
        title = [NSString stringWithFormat:@"%d", [userObject getCurrentDay]];
        suffix = [userObject getDaysLeftString];
        [tabDay.labelPrefix setText:@"Day"];
        [tabDay.labelTitle setText:title];
        [tabDay.labelSuffix setText:suffix];
    }
    else {
        title = [NSString stringWithFormat:@"%d", [userObject getDaysAged]];
        [tabDay.labelPrefix setText:@"Aged"];
        [tabDay.labelTitle setText:title];
        [tabDay.labelSuffix setText:@"Days"];
    }
}

- (void)onItemEdited
{
    [self updateDayTab];
    [self setupDay];
    
    
    [self.parent onItemAdded];
}


@end
