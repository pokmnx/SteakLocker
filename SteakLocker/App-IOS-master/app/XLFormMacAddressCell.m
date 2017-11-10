//
//  XLFormMacAddressCell.m
//  ELA
//
//  Created by Xcode on 8/23/17.
//  Copyright © 2017 ELA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLFormMacAddressCell.h"
#import "ELA.h"

NSString * const XLFormRowDescriptorTypeMacAddress = @"XLFormRowDescriptorMacAddress";

@implementation XLFormMacAddressCell

+(void)load
{
    [[XLFormViewController cellClassesForRowDescriptorTypes] setObject:[XLFormMacAddressCell class] forKey:XLFormRowDescriptorTypeMacAddress];
}

-(void) configure {
    [super configure];
    
    CGRect scrn = [ELA getScreen];
    
    [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
    
    UIView* statusBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrn.size.width, 81)];
    [statusBg setBackgroundColor:[UIColor clearColor]];
    [self addSubview:statusBg];
    
    self.btnConnect = [[UIButton alloc] initWithFrame:CGRectMake(50, 0, scrn.size.width-100, 60)];
    [self.btnConnect.titleLabel setFont:[ELA getFont:16]];
    
    NSString* macAddress = [NSString stringWithFormat:@"%@\nMac Address", [ELA currentWifiBSSID]];
    [self.btnConnect setTitle:macAddress forState:UIControlStateNormal];
    [self.btnConnect setTitleColor:[UIColor colorWithRed:160.0f/255.0f green:160.0f/255.0f blue:160.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [self.btnConnect setBackgroundColor:[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0f]];
    self.btnConnect.layer.borderColor = [UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.0f].CGColor;
    self.btnConnect.layer.cornerRadius = 35;
    self.btnConnect.layer.borderWidth = 1;
    [self.btnConnect setClipsToBounds:true];
    [self.btnConnect.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.btnConnect.titleLabel setNumberOfLines:2];
    [self.btnConnect.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.btnConnect setTitleColor:[UIColor colorWithWhite:0 alpha:0] forState:UIControlStateHighlighted];
    
    [self.btnConnect addTarget:self action:@selector(copyMacAddressToClipboard) forControlEvents:UIControlEventTouchUpInside];
    [statusBg addSubview:self.btnConnect];
    [statusBg bringSubviewToFront:self.btnConnect];
    
    self.tapLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, scrn.size.width, 21)];
    [self.tapLabel setFont:[ELA getFont:13]];
    [self.tapLabel setTextAlignment:NSTextAlignmentCenter];
    [self.tapLabel setText:@"tap to copy"];
    [self.tapLabel setTextColor:[UIColor colorWithRed:198.0f/255.0f green:198.0f/255.0f blue:198.0f/255.0f alpha:1.0f]];
    [statusBg addSubview:self.tapLabel];
}

-(void)copyMacAddressToClipboard {
    [self.btnConnect setHidden:true];
    [self.tapLabel setHidden:true];
    
    [[UIPasteboard generalPasteboard] setString:[ELA currentWifiBSSID]];
}

+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor
{
    return 81;
}

@end

