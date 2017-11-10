//
//  MeasurementProgressView.h
//  Steak Locker
//
//  Created by Jared Ashlock on 10/18/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef Steak_Locker_MeasurementProgressView_h
#define Steak_Locker_MeasurementProgressView_h

@interface MeasurementProgressView : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic) BOOL active;
@property (nonatomic) float min;
@property (nonatomic) float max;
@property (nonatomic, strong) UIColor *colorLine;
@property (nonatomic, strong) UIColor *colorLineInactive;
@property (nonatomic, strong) UIColor *colorText;
@property (nonatomic, strong) UIColor *colorBg;
@property (nonatomic, strong) UIColor *colorBgActive;
@property (nonatomic, strong) UIProgressView *viewProgress;
@property (nonatomic, strong) UILabel *labelTitle;

- (instancetype)initWithFrame:(CGRect)frame title: (NSString*)title color:(UIColor*)color;

- (void)setLimits: (float)min max: (float)max;
- (void)setProgress: (float)progress;
- (void)setViewActive: (BOOL) active;
@end


#endif
