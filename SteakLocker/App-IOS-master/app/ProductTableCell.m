//
//  ProductTableCell.m
//  Steak Locker
//
//  Created by Jared Ashlock on 10/21/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductTableCell.h"
#import "ELA.h"

@implementation ProductTableCell


-(BOOL)isBadAgingType
{
    Object *object = self.mUserObject.object;
    if (object != nil) {
        NSString *userAgingType = [ELA getAgingType];
        NSString *agingType = [object getAgingType];
        return ![agingType isEqualToString:userAgingType];
    }
    return NO;
}

//setting the frames of views within the cell
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setSeparatorInset:UIEdgeInsetsZero];
    
    
    CGRect fr = self.imageView.frame;
    float diff = fr.size.width - fr.size.height;
    float imageWidth = fr.size.width;
    fr.size.width = fr.size.height;
    self.imageView.frame = fr;
    
    fr = self.textLabel.frame;
    fr.origin.x -= diff;
    fr.size.width += diff;
    self.textLabel.frame = fr;

    fr = self.detailTextLabel.frame;
    fr.origin.x -= diff;
    fr.size.width += diff;
    self.detailTextLabel.frame = fr;
    
    if ([self isBadAgingType]) {
        CGFloat width = self.frame.size.width - imageWidth - 40;

        fr = self.textLabel.frame;
        if (fr.size.width > width) {
            fr.size.width = width;
            self.textLabel.frame = fr;
        }

        
        fr = self.frame;
        UIColor *warningColor = [ELA getColorTypeWarning];
        if (self.warningBg == nil) {
            self.warningBg = [[UIView alloc] initWithFrame:CGRectMake(fr.size.width-40, 0, 40, fr.size.height)];
            [self addSubview: self.warningBg];
        }
        [self.warningBg setBackgroundColor:warningColor];

        
        if (self.warningIcon == nil) {
            CGFloat y = (fr.size.height - 20.0f) / 2.0f;
            self.warningIcon = [[UIImageView alloc] initWithFrame: CGRectMake(10, y, 20.0f, 20.0f)];
            [self.warningIcon setImage:[UIImage imageNamed:@"WarningIcon"]];
            [self.warningIcon setContentMode:UIViewContentModeScaleAspectFill];
            [self.warningBg addSubview:self.warningIcon];
        }
    }
    else {
        if (self.warningIcon != nil) {
            [self.warningIcon removeFromSuperview];
            self.warningIcon = nil;
        }
        if (self.warningBg != nil) {
            [self.warningBg removeFromSuperview];
            self.warningBg = nil;
        }
    }
    

    
}

@end
