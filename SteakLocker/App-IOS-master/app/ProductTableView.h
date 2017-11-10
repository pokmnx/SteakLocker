//
//  ProductTableView.h
//  Steak Locker
//
//  Created by Jared Ashlock on 10/21/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <Realm/Realm.h>

#ifndef Steak_Locker_ProductTableView_h
#define Steak_Locker_ProductTableView_h

@interface ProductTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) RLMResults *objects;
@property (nonatomic, strong) UIViewController *parentController;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic) BOOL activeItems;

- (instancetype)initWithFrame:(CGRect)frame items: (NSArray*) objects;

@end

#endif
