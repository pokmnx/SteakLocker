//
//  MeasurementProgressView.m
//  Steak Locker
//
//  Created by Jared Ashlock on 10/18/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeasurementProgressView.h"
#import "ELA.h"

@interface MeasurementProgressView ()

@end

@implementation MeasurementProgressView

    @synthesize title;
    @synthesize active;
    @synthesize colorLine;
    @synthesize colorLineInactive;
    @synthesize colorText;
    @synthesize colorBg;
    @synthesize colorBgActive;
    @synthesize viewProgress;
    @synthesize labelTitle;
    

- (instancetype)initWithFrame:(CGRect)frame title: (NSString*)sTitle color:(UIColor*)color
{
    self.title = sTitle;
    self.colorLine = color;
    
    self.min = 0.0f;
    self.max = 100.0f;
    
    return [super initWithFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    colorBg = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
    colorBgActive = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
    colorText = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    colorLineInactive = [UIColor colorWithRed:130.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:1.0f];
    
    [self setBackgroundColor:colorBg];
    
    labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(20,20,280,20)];
    [labelTitle setText: title];
    [labelTitle setTextColor: colorText];
    [labelTitle setFont: [ELA getFontThin: 16]];
    [self addSubview: labelTitle];
    
    
    CGRect scrn = [ELA getScreen];
    int margin = 20;
    
    viewProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(margin, 50, scrn.size.width - (2*margin), 10)];
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
    [viewProgress setTransform:transform];
    [viewProgress setProgressTintColor:colorLine];
    [self addSubview: viewProgress];
}

-(void) setLimits:(float)fMin max:(float)fMax
{
    self.min = fMin;
    self.max = fMax;
}

-(void) setProgress: (float) progress
{
    float value = (progress - self.min) / (self.max - self.min);
    
    [viewProgress setProgress:value animated:NO];
}
- (void)setViewActive: (BOOL) isActive
{
    self.active = isActive;
    
    if (isActive) {
        [self setBackgroundColor:colorBgActive];
        [labelTitle setTextColor:colorLine];
        
        NSString *t = [NSString stringWithFormat:@"%@  •", self.title];
        [labelTitle setText: t];
        [viewProgress setProgressTintColor:colorLine];
    } else {
        [self setBackgroundColor:colorBg];
        [labelTitle setTextColor:colorText];
        [labelTitle setText: self.title];
        [viewProgress setProgressTintColor:colorLineInactive];
    }
}

@end
