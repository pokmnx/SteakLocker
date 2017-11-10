//
//  ProductTableCell.h
//  Steak Locker
//
//  Created by Jared Ashlock on 10/21/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SLModels.h"
#import <ParseUI/ParseUI.h>

#ifndef Steak_Locker_ProductTableCell_h
#define Steak_Locker_ProductTableCell_h

@interface ProductTableCell : PFTableViewCell

@property (nonatomic, strong) UserObject *mUserObject;
@property (nonatomic, strong) UIView *warningBg;
@property (nonatomic, strong) UIImageView *warningIcon;

-(BOOL)isBadAgingType;

@end


#endif
