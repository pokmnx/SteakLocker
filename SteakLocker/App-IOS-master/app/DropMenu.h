//
//  DropMenu.h
//  Steak Locker
//
//  Created by Jared Ashlock on 10/23/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef Steak_Locker_DropMenu_h
#define Steak_Locker_DropMenu_h


@interface DropMenu : UIView


@property (nonatomic) BOOL showing;
@property (nonatomic, strong) NSString *activeItemName;
@property (nonatomic, strong) UIViewController *parent;
@property (nonatomic, strong) UINavigationController *nav;
@property (nonatomic, retain) NSMutableArray *menuItems;
@property (nonatomic, strong) UIImageView *blurredImage;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)showMenu;
- (void)hideMenu;

@end


@interface DropMenuItem : UIView

@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL isActive;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) DropMenu *menu;
@property (nonatomic) CGRect myFrame;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString*)stitle icon: (NSString*)sicon;

- (void)setActiveItem:(BOOL)bActive;

@end


#endif