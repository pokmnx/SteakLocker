//
//  XLFormMacAddressCell.h
//  ELA
//
//  Created by Xcode on 8/23/17.
//  Copyright © 2017 ELA. All rights reserved.
//

#import "XLFormBaseCell.h"


extern NSString * const XLFormRowDescriptorTypeMacAddress;

@interface XLFormMacAddressCell : XLFormBaseCell

@property (nonatomic, strong) UIButton* btnConnect;
@property (nonatomic, strong) UILabel* tapLabel;

@end
