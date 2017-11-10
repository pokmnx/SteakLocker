
//
//  SignInController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

@import UIKit;
#import "SetupChooserController.h"
#import "ELA.h"
#import "ELADevice.h"

@interface SetupChooserController ()

@end

@implementation SetupChooserController


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
    
}


- (IBAction)onBack: (id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    [ELA dismissStoryboard: self];
}


- (IBAction)onNext: (XLFormRowDescriptor *)sender
{
    XLFormOptionsObject * value;
    NSString *series;
    NSString *model;
    
    [self deselectFormRow:sender];
    
    value = [self.rowSeries value];
    series = value.formValue;
    value = [self.rowModel value];
    model = value.formValue;
    
    ELADevice *elaDevice = [ELA getElaDevice];
    elaDevice.model = model;
    
    
    if ([series isEqualToString:@"home"] && [model isEqualToString:@"SL103"]) {
        [ELA loadStoryboard:self storyboard:@"Setup"];
    }
    else {
        
        [ELA loadStoryboard:self storyboard:@"WifiSetup"];
    }
}

- (void)openWifiSettings
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"prefs:root=WIFI"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=WIFI"]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    [backButton setTintColor:[ELA getColorAccent]];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor  = [ELA getColorBGLight];
    self.view.backgroundColor = [ELA getColorBGLight];

    self.imageProduct = [ELA addImage:@"imgSmallUnit" frame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 0.83)];
    [self.imageProduct setUserInteractionEnabled:YES];
	self.tableView.tableHeaderView = self.imageProduct;


    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProduct:)];
    [self.tableView.tableHeaderView addGestureRecognizer:recognizer];
}

- (BOOL)isHomeSeriesSelected
{
    XLFormOptionsObject *option = (XLFormOptionsObject *)self.rowSeries.value;
    return [option.formValue isEqualToString:@"home"];
}

- (IBAction)tapProduct:(id)sender
{
    BOOL isHome = [self isHomeSeriesSelected];
    self.rowSeries.value = (isHome) ? [self getSeriesProOption] : [self getSeriesHomeOption];
    [self reloadFormRow:self.rowSeries];

}

- (void)updateProductImage
{
    BOOL isHome = [self isHomeSeriesSelected];
    [self.imageProduct setImage:[UIImage imageNamed:((isHome) ? @"imgSmallUnit" : @"imgProUnit")]];
}

- (XLFormOptionsObject *)getSeriesHomeOption
{
    return [XLFormOptionsObject formOptionsObjectWithValue:@"home" displayText:@"Home Series"];
}
- (XLFormOptionsObject *)getSeriesProOption
{
    return [XLFormOptionsObject formOptionsObjectWithValue:@"pro" displayText:@"Professional Series"];
}

-(void)initializeForm
{
    XLFormDescriptor *form;
    XLFormSectionDescriptor * section;
    
    form = [XLFormDescriptor formDescriptor];
    section = [XLFormSectionDescriptor formSectionWithTitle: @"Select"];
    section.footerTitle = @"Setup is specific to your model number. Please ensure your model number is correct and contact support if you have any questions.";
    
    [form addFormSection:section];

    XLFormRowDescriptor * series = [XLFormRowDescriptor formRowDescriptorWithTag:@"series" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Series"];
    series.required = YES;
    XLFormOptionsObject *seriesHome = [self getSeriesHomeOption];
    XLFormOptionsObject *seriesPro  = [self getSeriesProOption];
	series.selectorOptions = @[seriesHome, seriesPro];

	if (!self.rowSeries || [((XLFormOptionsObject *)self.rowSeries.value).formValue isEqualToString:@"home"] ) {
		series.value = seriesHome;
	}
	else {
		series.value = seriesPro;
	}
	self.rowSeries = series;

    [section addFormRow: self.rowSeries];
    
    self.rowModel = [XLFormRowDescriptor formRowDescriptorWithTag:@"model" rowType: XLFormRowDescriptorTypeSelectorPush title:@"Model #"];
    self.rowModel.required = YES;
    
    [section addFormRow:self.rowModel];

    [self updateModelBySeries:NO];
    

    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    // Button
    XLFormRowDescriptor * buttonRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"startSetup" rowType:XLFormRowDescriptorTypeButton title:@"Next"];
    
    buttonRow.height = 90.0f;

    [buttonRow.cellConfig setObject:[ELA getColorAccent] forKey:@"backgroundColor"];
    [buttonRow.cellConfig setObject:[UIColor whiteColor] forKey:@"textLabel.textColor"];
    [buttonRow.cellConfig setObject:[ELA getFont:20.0f] forKey:@"textLabel.font"];

    // Do this to hack the XLForm button to be rounded, since is actually a tableviewcell masquerading as a button
    [buttonRow.cellConfig setObject:@(45.0f) forKey:@"layer.cornerRadius"];
    [buttonRow.cellConfig setObject:@(YES) forKey:@"clipsToBounds"];
    [buttonRow.cellConfig setObject:@(15.0f) forKey:@"layer.borderWidth"];
    [buttonRow.cellConfig setObject:[ELA getColorBGLight].CGColor forKey:@"layer.borderColor"];

    buttonRow.action.formSelector = @selector(onNext:);
    [section addFormRow:buttonRow];
    
    self.form = form;
    self.form.delegate = self;
}

- (void)updateModelBySeries: (BOOL) reload
{
    if ([self isHomeSeriesSelected]) {
        XLFormOptionsObject *modelSL103 = [XLFormOptionsObject formOptionsObjectWithValue:@"SL103" displayText:@"SL103"];
        XLFormOptionsObject *modelSL150 = [XLFormOptionsObject formOptionsObjectWithValue:@"SL150" displayText:@"SL150"];;
        self.rowModel.selectorOptions = @[modelSL103, modelSL150];
        self.rowModel.value = modelSL150;
    }
    else {
        XLFormOptionsObject *modelSL520 = [XLFormOptionsObject formOptionsObjectWithValue:@"SL520" displayText:@"SL520"];
        self.rowModel.selectorOptions = @[modelSL520];
        self.rowModel.value = modelSL520;
    }

    if (reload) {
        [self reloadFormRow:self.rowModel];
    }
}


-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {

	if (formRow == self.rowSeries) {
		[self updateModelBySeries: YES];
        [self updateProductImage];
	}
}


@end
