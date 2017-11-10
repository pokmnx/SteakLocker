//
//  MeasurementProgressView.h
//  Steak Locker
//
//  Created by Jared Ashlock on 10/18/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObjectTabView : UIView

@property (nonatomic) BOOL active;
@property (nonatomic) BOOL useIcon;

@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *suffix;

@property (nonatomic, strong) UILabel *labelPrefix;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UIImageView *imageIcon;
@property (nonatomic, strong) UILabel *labelSuffix;

- (instancetype)initWithFrame:(CGRect)frame prefix: (NSString*)prefix title:(NSString*)title suffix:(NSString*)suffix active:(BOOL)active;
- (instancetype)initWithFrame:(CGRect)frame prefix: (NSString*)prefix icon:(NSString*)icon suffix:(NSString*)suffix active:(BOOL)active;

- (void)setViewActive: (BOOL) active;
@end

