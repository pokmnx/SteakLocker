//
//  ItemController.h
//  Steak Locker
//
//  Created by Jared Ashlock on 10/21/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ELA.h"
#import "ObjectTabView.h"
#import "NutritionViewController.h"
#import "ItemsController.h"
#import "XLForm.h"
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"
#import "SLModels.h"

@interface ItemController : UIViewController

@property (nonatomic, strong) UserObject *userObject;

@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *labelNickname;
@property (nonatomic, strong) ObjectTabView *tabDay;
@property (nonatomic, strong) ObjectTabView *tabNutrition;
@property (nonatomic, strong) ObjectTabView *tabInfo;
@property (nonatomic, strong) UIScrollView *pageDay;
@property (nonatomic, strong) UIScrollView *pageNutrition;
@property (nonatomic, strong) UIWebView *pageInfo;

@property (nonatomic, strong) MDRadialProgressView *radialDays;
@property (nonatomic, strong) UILabel *labelDaysAged;
@property (nonatomic, strong) UIButton *btnRemove;

@property (nonatomic, strong) ItemsController *parent;

- (void)onEdit;
- (void)onItemEdited;

- (void)handleTapDay:(UITapGestureRecognizer *)recognizer;
- (void)handleTapNutrition:(UITapGestureRecognizer *)recognizer;
- (void)handleTapInfo:(UITapGestureRecognizer *)recognizer;

@end

