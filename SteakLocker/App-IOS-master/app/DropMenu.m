//
//  DropMenu.m
//  Steak Locker
//
//  Created by Jared Ashlock on 10/23/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DropMenu.h"
#import "ELA.h"
#import "SLModels.h"
#import "DashboardController.h"
#import "SVPullToRefresh.h"

@interface DropMenuItem ()
- (void)commonInit: (NSString*)title icon:(NSString*)icon;
-(void)handleTapMenuItem:(UITapGestureRecognizer *)tapGestureRecognizer;
@end

@implementation DropMenuItem
@synthesize name;
@synthesize label;
@synthesize icon;
@synthesize line;
@synthesize isActive;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString*)stitle icon: (NSString*)sicon;
{
    self = [super init];
    self.name = stitle;
    self.frame = frame;
    self.myFrame = frame;
    [self commonInit:stitle icon:sicon];
    return self;
}

- (void)commonInit: (NSString*)stitle icon:(NSString*)sicon;
{
    CGRect scrn = [[UIScreen mainScreen] bounds];
    
    self.backgroundColor = [ELA getColorBGDark];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, scrn.size.width-100, 50)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = stitle;
    label.textColor = [UIColor whiteColor];
    label.font = [ELA getFont:20.0f];
    
    [self addSubview: label];
    
    
    icon = [ELA addImage:sicon X:0 Y:0 W:50 H:50];
    [self addSubview: icon];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, 49, scrn.size.width, 1)];
    line.backgroundColor = [ELA getColorBGDarker];
    [self addSubview:line];
    [self bringSubviewToFront:line];
    
    
    UITapGestureRecognizer *tapMenuItem;
    tapMenuItem = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapMenuItem:)];
    [self addGestureRecognizer:tapMenuItem];
}

- (void)setActiveItem:(BOOL)bActive
{
    if (bActive) {
        isActive = YES;
        self.backgroundColor = [ELA getColorAccent];
    }
    else {
        isActive = NO;
        self.backgroundColor = [ELA getColorBGDark];
    }
}

-(void)handleTapMenuItem:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (isActive) {
        [self.menu hideMenu];
    }
    else {
        
        DropMenuItem *view = (DropMenuItem *)tapGestureRecognizer.view;
        view.backgroundColor = [ELA getColorBGDarker];
        UIStoryboard *sb = [UIStoryboard storyboardWithName: view.name bundle:nil];
        UIViewController *vc = [sb instantiateViewControllerWithIdentifier: view.name];
        [self.menu.parent presentViewController:vc animated:NO completion:nil];
    }

}

@end



@interface DropMenu ()
-(void)handleTapBlurredImage:(UITapGestureRecognizer *)tapGestureRecognizer;
@end

@implementation DropMenu

@synthesize showing;
@synthesize activeItemName;
@synthesize parent;
@synthesize nav;
@synthesize menuItems;
@synthesize blurredImage;


- (instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame: frame];
    self.frame = frame;
    [self commonInit];
    return self;
}

- (void)commonInit
{
    CGRect scrn = [[UIScreen mainScreen] bounds];
    
    blurredImage = [[UIImageView alloc] init];
    blurredImage.userInteractionEnabled = YES;
    blurredImage.frame = scrn;
    blurredImage.alpha = 0.0f;
    [self addSubview:blurredImage];
    
    UITapGestureRecognizer *tapBlurredImage;
    tapBlurredImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBlurredImage:)];
    [blurredImage addGestureRecognizer:tapBlurredImage];
    
    
    menuItems = [[NSMutableArray alloc] init];
    
    NSArray *items = @[@"Dashboard", @"Items", @"Reports", @"Videos", @"Settings"];
    
    CGRect frame = CGRectMake(0, 0, scrn.size.width, 50);
    for (NSString *item in items) {
        NSString *sIcon = [NSString stringWithFormat:@"IconMenu%@", item];
        DropMenuItem *menuItem = [[DropMenuItem alloc] initWithFrame:frame title:item icon:sIcon];
        menuItem.alpha = 0.0f;
        menuItem.menu = self;
        
        [menuItems addObject:menuItem];
        [self addSubview:menuItem];
        frame.origin.y += frame.size.height;
    }
}

- (void)showMenu {
    if (self.showing) {
        return;
    }

    CGRect rect;
    for (DropMenuItem *menuItem in menuItems) {
        [self bringSubviewToFront:menuItem];

        rect = menuItem.myFrame;
        rect.origin.y = 0;
        menuItem.frame = rect;
        menuItem.isActive = false;
        menuItem.alpha = 1.0f;
    }
    
    DashboardController *dash = nil;
    UIView *parentView = parent.view;
    
    if ([parentView isKindOfClass: [UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView*)parentView;
        scrollView.scrollEnabled = NO;
    }
    
    int offsetY = 0;

    if (dash != nil){
        [dash getScroll].showsPullToRefresh = YES;
    }
    

    blurredImage.alpha = 1.0f;

    
    
    DropMenuItem *activeItem = nil;
    int Y = offsetY;
    float animationTime = 0.00f;
    float animationTimeSum = 0.10f;
    float animationSpeedup = 0.02f;
    for (DropMenuItem *menuItem in menuItems) {
    
  //      [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration: animationTime];
        
        rect = menuItem.frame;
        rect.origin.y = Y;
        menuItem.frame = rect;
        Y += 50;
        animationTime += animationTimeSum;
        animationTimeSum -= animationSpeedup;
        
        if (menuItem.name == activeItemName) {
            activeItem = menuItem;
        }
    //    [UIView commitAnimations];
    }
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.3f];
    
    if (activeItem != nil) {
        [activeItem setActiveItem:YES];
    }
    [UIView commitAnimations];
    
    self.showing = YES;
}

- (void)hideMenu {
    if (!self.showing) {
        return;
    }
    
    UIView *parentView = parent.view;
    if ([parentView isKindOfClass: [UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView*)parentView;
        scrollView.scrollEnabled = YES;
    }
    
    blurredImage.alpha = 0.0f;
    for (DropMenuItem *menuItem in menuItems) {
        menuItem.alpha = 0.0f;
    }
    self.showing = NO;
}

-(void)handleTapBlurredImage:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self hideMenu];
    self.alpha = 0.0f;
    [self.parent.view sendSubviewToBack:self];
}

@end
