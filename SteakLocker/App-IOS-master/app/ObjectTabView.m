//
//  MeasurementProgressView.m
//  Steak Locker
//
//  Created by Jared Ashlock on 10/18/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ObjectTabView.h"
#import "ELA.h"

@interface ObjectTabView ()

@end

@implementation ObjectTabView

    @synthesize prefix;
    @synthesize title;
    @synthesize suffix;
    @synthesize labelPrefix;
    @synthesize labelTitle;
    @synthesize imageIcon;
    @synthesize labelSuffix;

    

- (instancetype)initWithFrame:(CGRect)frame prefix:(NSString*)sPrefix title:(NSString*)sTitle suffix:(NSString*)sSuffix active:(BOOL)bActive;
{
    self.prefix = sPrefix;
    self.title = sTitle;
    self.suffix = sSuffix;
    self.active = bActive;
    
    return [super initWithFrame:frame];
}


- (instancetype)initWithFrame:(CGRect)frame prefix:(NSString*)sPrefix icon:(NSString*)sIcon suffix:(NSString*)sSuffix active:(BOOL)bActive;
{
    self.prefix = sPrefix;
    self.title = sIcon;
    self.suffix = sSuffix;
    self.useIcon = true;
    self.active = bActive;
    
    return [super initWithFrame:frame];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frameSelf = self.frame;
    
    if (self.active) {
        [self setBackgroundColor: [ELA getColorAccent]];
    }
    else {
        [self setBackgroundColor: [ELA getColorBGDark]];
    }

    

    labelPrefix = [[UILabel alloc] initWithFrame:CGRectMake(0,5, frameSelf.size.width,15)];
    [labelPrefix setFont: [ELA getFontBold:10.0f]];
    [labelPrefix setTextColor: [UIColor whiteColor]];
    labelPrefix.textAlignment = NSTextAlignmentCenter;
    [labelPrefix setText: prefix];
    [self addSubview: labelPrefix];
    
    if (self.useIcon) {
        imageIcon = [ELA addImage:self.title frame:CGRectMake(0,28, frameSelf.size.width,24)];
        [self addSubview: imageIcon];
        [self bringSubviewToFront:imageIcon];
    }
    else {
        labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,25, frameSelf.size.width,30)];
        [labelTitle setFont: [ELA getFontThin:30.0f]];
        [labelTitle setTextColor: [UIColor whiteColor]];
        labelTitle.textAlignment = NSTextAlignmentCenter;
        [labelTitle setText: title];
        [self addSubview: labelTitle];
    }
        
    labelSuffix = [[UILabel alloc] initWithFrame:CGRectMake(0,60, frameSelf.size.width,15)];
    [labelSuffix setFont: [ELA getFontItalic:10.0f]];
    [labelSuffix setTextColor: [UIColor whiteColor]];
    labelSuffix.textAlignment = NSTextAlignmentCenter;
    [labelSuffix setText: suffix];
    [self addSubview: labelSuffix];
}

- (void)setViewActive: (BOOL) isActive
{
    self.active = isActive;
    
    if (isActive) {
        [self setBackgroundColor: [ELA getColorAccent]];
    } else {
        [self setBackgroundColor: [ELA getColorBGDark]];
    }
}

@end
