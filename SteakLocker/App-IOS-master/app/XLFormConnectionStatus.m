//  XLFormWeekDaysCell.m
//  XLForm ( https://github.com/xmartlabs/XLForm )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "XLFormConnectionStatus.h"
#import "ELA.h"
#import "ELADevice.h"

NSString * const XLFormRowDescriptorTypeConnectionStatus = @"XLFormRowDescriptorConnectionStatus";


@interface XLFormConnectionStatusCell()
@property (strong, nonatomic) UIView *statusBg;
@property (strong, nonatomic) UILabel *status;
@property (strong, nonatomic) UILabel *desc;
@property (strong, nonatomic) UIButton *btnConnect;
@end

@implementation XLFormConnectionStatusCell

+(void)load
{
    [[XLFormViewController cellClassesForRowDescriptorTypes] setObject:[XLFormConnectionStatusCell class] forKey:XLFormRowDescriptorTypeConnectionStatus];
}

#pragma mark - XLFormDescriptorCell

- (void)configure
{
    [super configure];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configureMe];

    [ELA on:@"socketConnected" notify:^{
        [self updateConnected: [ELA getElaDevice]];
    }];
    /*
    [ELA on:@"socketDidDisconnect" notify:^{
        [self updateConnected: [ELA getElaDevice]];
    }];
     */
}

-(void)update
{
    [super update];
    
    ELADevice *elaDevice = [ELA getElaDevice];
    
    [self updateMe: elaDevice];
}

#pragma mark - Action

- (IBAction)connectTapped:(id)sender
{
    if ([self.btnConnect isHidden]) {
        
    }
    else {
        [ELA openWifiSettings];
    }
}

#pragma mark - Helpers

-(void)configureMe
{
    CGRect scrn = [ELA getScreen];
    
    self.separatorInset = UIEdgeInsetsMake(0.f, self.bounds.size.width, 0.f, 0.f);
    
    [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
    
    self.statusBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrn.size.width, 50)];
    [self.statusBg setBackgroundColor:[UIColor colorWithRed: 221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:1.0f]];
    [self addSubview:self.statusBg];
    

    self.status = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, scrn.size.width-115, 50)];
    [self.status setFont:[ELA getFont:13]];
    self.desc = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, scrn.size.width-30, 100)];
    [self.desc setFont:[ELA getFont:17]];
    [self.desc setNumberOfLines:0];
    [self.desc setTextAlignment:NSTextAlignmentCenter];
    
    
    [self.statusBg addSubview:self.status];
    [self.statusBg addSubview:self.desc];
    
    
    self.btnConnect = [[UIButton alloc] initWithFrame:CGRectMake(scrn.size.width - 100, 0, 100, 50)];
    [self.btnConnect.titleLabel setFont:[ELA getFont:13]];
    
    [self.btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
    [self.btnConnect setTitleColor:[ELA getColorAccent] forState:UIControlStateNormal];
    [self.btnConnect setTitle:@"" forState:UIControlStateDisabled];
    [self.btnConnect setTitleColor:[UIColor colorWithWhite:0 alpha:0] forState:UIControlStateDisabled];
    [self.btnConnect addTarget:self action:@selector(connectTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.statusBg addSubview:self.btnConnect];
    [self.statusBg bringSubviewToFront:self.btnConnect];
}

- (void)updateConnected:(ELADevice * _Nonnull)elaDevice
{
    BOOL socketConnected = [elaDevice isConnectedToDeviceSocket];
    
    [self.status setText:@"Connected to Steak Locker WiFi"];
    
    if (elaDevice.uniqueId && socketConnected) {
        [self.desc setText:@"Perfect, we’ve found your device. One last step."];
    }
    else if (socketConnected) {
        [self.desc setText:@"Connecting to your locker... reading settings..."];
        
        [elaDevice readSettings];
    }
    else {
        [self.desc setText:@"Connecting to your locker..."];
    }
    
    [self.btnConnect setHidden:YES];
}

-(void)updateMe: (ELADevice * _Nonnull)elaDevice
{
    BOOL connected = [elaDevice isConnectedToDeviceWifi];
    
    if (connected) {
        [self updateConnected: elaDevice];
    }
    else {
        [self.status setText:@"Steak Locker Not Connected"];
        [self.desc setText:@"Oops, you're not connected to the Steak Locker Wifi. Please Connect and return to continue."];

        [self.btnConnect setHidden:NO];
    }
}




-(void)imageTopTitleBottom:(UIButton *)button
{
    // the space between the image and text
    CGFloat spacing = 3.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = button.imageView.image.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
    button.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
}

+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor
{
    return 170;
}


@end
