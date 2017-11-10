//
//  DashboardController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import "ItemsController.h"
#import <Parse/Parse.h>
#import "DropdownController.h"
#import "ELA.h"
#import "ItemController.h"
#import "SVPullToRefresh.h"
#import "ObjectController.h"

@interface ItemsController ()


- (int)getHeaderHeight;

@end

@implementation ItemsController

@synthesize tableItems;
@synthesize tableItemsPast;
@synthesize btnAddPrompt;
@synthesize labelAddPrompt;


- (UIScrollView*)getScroll
{
    return (UIScrollView*)self.view;
}
- (int)getHeaderHeight
{
    return self.navigationController.navigationBar.frame.size.height + [ELA getStatusBarHeight];
}


-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

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
    
    CGRect scrn = [ELA getScreen];
    float headerHeight = [ELA getHeaderHeight:self];
    
    [self.view setBackgroundColor: [ELA getColorBGLight]];

    
    NSArray *itemArray = [NSArray arrayWithObjects: @"Current", @"Past", nil];
    self.segments = [[UISegmentedControl alloc] initWithItems:itemArray];
    [self.segments setFrame: CGRectMake(15, 10, scrn.size.width-30, 30)];
    [self.segments setTintColor:[ELA getColorAccent]];
    
    [self.segments addTarget:self action:@selector(onSegment:) forControlEvents: UIControlEventValueChanged];
    self.segments.selectedSegmentIndex = 0;
    [self.view addSubview:self.segments];

    //int y = arrowDown.frame.origin.y + arrowDown.frame.size.height;
    int y = 50;
    int count = 0;
    float heightRow = 80.0f;
    float heightHeader = 50.0f;
    float height = (count *  heightRow) + heightHeader;
    
    tableItems = [[ProductTableView alloc] initWithFrame:CGRectMake(0, y, scrn.size.width, scrn.size.height-headerHeight- y) items: nil];
    tableItems.rowHeight = heightRow;
    tableItems.parentController = self;
    tableItems.activeItems = YES;
    [tableItems setHidden:YES];
    [self.view addSubview: tableItems];
    [self.view sendSubviewToBack:tableItems];
    
    
    tableItemsPast = [[ProductTableView alloc] initWithFrame:CGRectMake(0, y, scrn.size.width, scrn.size.height-headerHeight- y) items: nil];
    tableItemsPast.rowHeight = heightRow;
    tableItemsPast.parentController = self;
    tableItemsPast.activeItems = NO;
    [tableItemsPast setHidden:YES];
    [self.view addSubview: tableItemsPast];
    [self.view sendSubviewToBack:tableItemsPast];
    
    

/*    [btnNext setClipsToBounds:YES];
    btnNext.layer.cornerRadius = 30;
    btnNext.layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.0f].CGColor;
  */
    CGRect framePrompt = CGRectMake(25, y+150, scrn.size.width-50, 60);
    framePrompt.size.height = 40;
    
    labelAddPrompt = [[UILabel alloc] initWithFrame:framePrompt];
    [labelAddPrompt setTextColor:[ELA getColorText]];
    [labelAddPrompt setFont: [ELA getFontThin:14]];
    [labelAddPrompt setText: @"You don't have any items in your locker."];
    [labelAddPrompt setTextAlignment:NSTextAlignmentCenter];
    [labelAddPrompt setHidden:YES];
    [self.view addSubview:labelAddPrompt];
    
    framePrompt.origin.y += framePrompt.size.height;
    framePrompt.size.height = 60;
    btnAddPrompt = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAddPrompt setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [btnAddPrompt setBackgroundColor: [ELA getColorAccent]];
    [btnAddPrompt setTitle:@"Add New Item" forState: UIControlStateNormal];
    [btnAddPrompt setFrame: framePrompt];
    [btnAddPrompt addTarget:self action:@selector(onAdd:) forControlEvents:UIControlEventTouchUpInside];
    [btnAddPrompt setHidden:YES];
    [self.view addSubview:btnAddPrompt];
    
    [self refreshObjects:^(BOOL success) {
        
    }];
}

- (void)onSegment:(UISegmentedControl *)segment
{
    [self updateDisplay];
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


- (void)refreshObjects:(void (^)(BOOL))callback
{
    PFObject* device = [ELA getUserDevice];
    RLMResults * results = [UserObject getUnremovedForDeviceId: device.objectId];
    RLMResults * results2 = [UserObject getRemovedForDeviceId: device.objectId];
    
    self.tableItems.objects = results;
    [self.tableItems reloadData];

    self.tableItemsPast.objects = results2;
    [self.tableItemsPast reloadData];
    
    [self updateDisplay];
    
    if (callback) {
        callback(YES);
    }
}

- (void)updateDisplay
{
    NSInteger index = self.segments.selectedSegmentIndex;
    
    
    [self.tableItems setHidden:YES];
    [self.tableItemsPast setHidden:YES];
    [self.labelAddPrompt setHidden:YES];
    [self.btnAddPrompt setHidden:YES];
    
    if (index == 0) {
        if (tableItems.objects.count > 0) {
            [self.tableItems setHidden:NO];
        }
        else {
            [self.labelAddPrompt setHidden:NO];
            [self.btnAddPrompt setHidden:NO];
        }
    }
    
    if (index == 1) {
        if (tableItemsPast.objects.count > 0) {
            [self.tableItemsPast setHidden:NO];
        }
        else {
            [self.labelAddPrompt setHidden:NO];
            [self.btnAddPrompt setHidden:NO];
        }
    }


}

- (IBAction)onMenu: (id)sender
{

    self.theMenu.activeItemName = @"Items";
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueItem"]) {
        ItemController * vc = [segue destinationViewController];
        vc.userObject = sender;
        vc.parent = self;
    }
}



- (void)onItemAdded
{
    [self refreshObjects:^(BOOL success) {

    }];
}


@end
