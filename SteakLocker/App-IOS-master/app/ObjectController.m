//
//  ObjectController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import "ObjectController.h"
#import <Parse/Parse.h>
#import "ELA.h"
#import "SLModels.h"
#import "DashboardController.h"
#import "ItemController.h"

@interface ObjectController () <MBProgressHUDDelegate>

@end

@implementation ObjectController
@synthesize hud;
@synthesize hudMsg;
@synthesize parent;
@synthesize rowCuts;

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.backgroundColor  =[ELA getColorBGLight];
    self.view.backgroundColor = [ELA getColorBGLight];
}
-(void)initializeForm
{
    XLFormDescriptor * form = [XLFormDescriptor formDescriptor];
    
    if (!self.isRemoving) {
        [form addFormSection: [self createSectionProductInfo]];
    }
    
    if ([ELA isProUser] || YES) {
        if (!self.isRemoving) {
            [form addFormSection: [self createSectionSalesInfo]];
            [form addFormSection: [self createSectionFoodControl]];
            [form addFormSection: [self createSectionExpectedPortions]];
        }
        if (!self.isAdding && (self.userObject.removedAt != nil || self.isRemoving)) {
            [form addFormSection: [self createSectionActualYield]];
        }
    }

    
    self.form = form;
    self.form.delegate = self;
    
}

- (void) reloadForm
{
    if (self.form != nil) {
        
        while (self.form.formSections.count > 0) {
            [self.form removeFormSectionAtIndex:0];
            
        }
    }
    [self initializeForm];
}

- (XLFormSectionDescriptor *) createSectionProductInfo
{
    UIFont *font = [ELA getFont:15.0f];
    XLFormRowDescriptor * row;
    UIColor *labelColor = [UIColor blackColor];
    
    PFObject *device = [ELA getUserDevice];
    NSString *agingType = [ELA getDeviceAgingType:device];
    
    XLFormSectionDescriptor * section = [XLFormSectionDescriptor formSectionWithTitle:@"Product Information"];
    
    // Selector Push
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"device" rowType:XLFormRowDescriptorTypeInfo title:@"Locker"];
    if (device != nil) {
        row.value = (NSString*)[device objectForKey:@"nickname"];
    }
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [section addFormRow:row];
    
    
    // Selector Push
    rowCuts = [XLFormRowDescriptor formRowDescriptorWithTag:@"object" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Cut of Meat"];
    
    rowCuts.required = YES;
    [rowCuts.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [rowCuts.cellConfig setObject:font forKey:@"textLabel.font"];
    [section addFormRow:rowCuts];
    [self initMeatCuts: agingType];
    
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"quality" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Grade/Quality"];
    row.required = YES;
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@"prime" displayText:@"Prime"];
    [section addFormRow:row];
    NSArray *opts = @[
                            [XLFormOptionsObject formOptionsObjectWithValue:@"prime" displayText:@"Prime"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@"choice" displayText:@"Choice"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@"select" displayText:@"Select"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@"custom" displayText:@"Custom"]
    ];
    row.selectorOptions = opts;    
    
    
    // NICKNAME
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"nickname" rowType:XLFormRowDescriptorTypeName title:@"Nickname"];
    // @TODO FIX
    //row.cellReturnKeyType = UIReturnKeyNext;
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    UIColor *infoColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:infoColor forKey:@"textLabel.color"];
    
    [row.cellConfig setObject:@"(optional)" forKey:@"textField.placeholder"];
    row.required = NO;
    
    [section addFormRow:row];
    
    
    NSString *label = [ELA isMetric] ? @"Weight (kg)" : @"Weight (lbs)";
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"weight" rowType:XLFormRowDescriptorTypeNumber title:label];
    // @TODO FIX
    //row.cellReturnKeyType = UIReturnKeyNext;
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    row.required = NO;
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    //    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    
    label = [ELA isMetric] ? @"Price / kg" : @"Price / lbs";
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"cost" rowType:XLFormRowDescriptorTypeNumber title:label];
    // @TODO FIX
    //row.cellReturnKeyType = UIReturnKeyNext;
    row.required = NO;
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [section addFormRow:row];
    
    
    // VENDOR
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"vendor" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Vendor"];
    
    RLMResults *vendors = [Vendor getAll];
    NSMutableArray *vendorOptions = [[NSMutableArray alloc] init];
    
    [vendorOptions addObject:[XLFormOptionsObject formOptionsObjectWithValue:@"other" displayText:@"Custom Vendor"]];
    for (Vendor *vendor in vendors) {
        [vendorOptions addObject:[XLFormOptionsObject formOptionsObjectWithValue:vendor.objectId displayText:vendor.title]];
    }
    
    row.selectorOptions = vendorOptions;
    row.required = NO;
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"days" rowType:XLFormRowDescriptorTypeNumber title:@"Days to Age"];
    // @TODO FIX
    [row.cellConfig setObject:@(UIReturnKeyNext) forKey:@"returnKeyType"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:@"Days in the locker" forKey:@"textField.placeholder"];
    row.required = YES;
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"startedAt" rowType:XLFormRowDescriptorTypeDateInline title:@"Start Date"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    row.value = [NSDate new];
    row.required = YES;
    [section addFormRow:row];
    
    
    if ([ELA isProUser] || YES) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"expectedLoss" rowType:XLFormRowDescriptorTypeNumber title:@"Expected Aging and Trimming Loss %"];
        // @TODO FIX
        [row.cellConfig setObject:@(UIReturnKeyDone) forKey:@"returnKeyType"];
        [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
        
        [row.cellConfig setObject:[ELA getFont:12.0f] forKey:@"textLabel.font"];
        [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
        
        
        
        [section addFormRow:row];
    }
    
    return section;
}


- (void)setCurrentUserObject: (UserObject*)userObject
{
    [self reloadForm];
    
    XLFormRowDescriptor * row;
    self.userObject = userObject;
    
    NSString * deviceId = self.userObject.deviceObjectId;
    PFObject *device = [ELA getUserDeviceById: deviceId];
    NSString *agingType = (device != nil) ? [ELA getDeviceAgingType:device] : TYPE_DRYAGING;

    
    if (!self.isRemoving) {
        row = [self.form formRowWithTag:@"device"];
        row.value = (NSString*)[device objectForKey:@"nickname"];
        [self updateFormRow:row];
    
        [self initMeatCuts: agingType];
        if (userObject.objectObjectId == nil || [userObject.objectObjectId isEqualToString:@""]) {
            rowCuts.value = [XLFormOptionsObject formOptionsObjectWithValue:@"other" displayText:@"Custom"];
        }
        else {
            Object *cut = [userObject object];
            if (cut != nil) {
                rowCuts.value = [XLFormOptionsObject formOptionsObjectWithValue:cut.objectId displayText:cut.title];
            }
        }
        [self updateFormRow:rowCuts];

        
        row = [self.form formRowWithTag:@"vendor"];
        if (userObject.customVendor != nil && ![userObject.customVendor isEqualToString:@""]) {
            row.value = [XLFormOptionsObject formOptionsObjectWithValue:@"other" displayText:@"Custom Vendor"];
            
            [self addCustomVendorRow];
        }
        else {
            if (userObject.vendorObjectId != nil) {
                Vendor *vendor = [Vendor objectForPrimaryKey: userObject.vendorObjectId];
                row.value = [XLFormOptionsObject formOptionsObjectWithValue:vendor.objectId displayText:vendor.title];
            }
        }
        [self updateFormRow:row];
        
        
        
        
        row = [self.form formRowWithTag:@"nickname"];
        row.value = userObject.nickname;
        [self updateFormRow:row];
        
        row = [self.form formRowWithTag:@"quality"];
        NSString *quality = (userObject.quality != nil) ? userObject.quality : @"custom";
        row.value = [XLFormOptionsObject formOptionsObjectWithValue:quality displayText:[quality capitalizedString]];
        [self updateFormRow:row];
        
        row = [self.form formRowWithTag:@"weight"];
        row.value = [NSString stringWithFormat:@"%.1f", userObject.weight];
        [self updateFormRow:row];
        
        row = [self.form formRowWithTag:@"cost"];
        row.value = [NSString stringWithFormat:@"%.2f", userObject.cost];
        [self updateFormRow:row];
        
        row = [self.form formRowWithTag:@"days"];
        row.value = [NSString stringWithFormat:@"%d", (int)userObject.days];
        [self updateFormRow:row];
        
        row = [self.form formRowWithTag:@"startedAt"];
        if (userObject.startedAt == nil) {
            row.value = [userObject backfillStartDate];
        }
        else {
            row.value = userObject.startedAt;
        }
        
        [self updateFormRow:row];
    }
    
    
    if ([ELA isProUser] || YES) {
        if (!self.isRemoving) {
            row = [self.form formRowWithTag:@"servingSize"];
            float servingSize = userObject.servingSize;
            if ([ELA isMetric]) {
                servingSize = [ELA ouncesToGrams:servingSize];
            }
            row.value = [NSString stringWithFormat:@"%.1f", servingSize];
            
            row = [self.form formRowWithTag:@"expectedLoss"];
            row.value = [NSString stringWithFormat:@"%d", (int)userObject.expectedLoss];
            
            row = [self.form formRowWithTag:@"servingSalePrice"];
            row.value = [NSString stringWithFormat:@"%.2f", userObject.servingPrice];
        }
        
        if (!self.isAdding) {
            row = [self.form formRowWithTag:@"removedAt"];
            if (row != nil) {
                if (userObject.removedAt == nil) {
                    row.value = [NSDate date];
                }
                else {
                    row.value = userObject.removedAt;
                }
            }
            row = [self.form formRowWithTag:@"weightEnd"];
            if (row != nil) {
                row.value = (userObject.weightEnd > 0) ? [NSString stringWithFormat:@"%.1f", userObject.weightEnd] : @"";
            }
        }
        
        [self updateSectionCalculations];
    }
}


- (XLFormSectionDescriptor *) createSectionSalesInfo
{
    UIFont *font = [ELA getFont:15.0f];
    XLFormRowDescriptor * row;
    UIColor *labelColor = [UIColor blackColor];
    
    XLFormSectionDescriptor * section = [XLFormSectionDescriptor formSectionWithTitle:@"Sales Information"];
    
    // Selector Push
    NSString *label = [ELA isMetric] ? @"Serving Size (g)" : @"Serving Size (oz)";
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"servingSize" rowType:XLFormRowDescriptorTypeNumber title:label];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [section addFormRow:row];
    
    
    
    // Selector Push
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"servingSalePrice" rowType:XLFormRowDescriptorTypeNumber title:@"Serving Sale Price"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [section addFormRow:row];
    
    return section;
}


- (XLFormSectionDescriptor *) createSectionFoodControl
{
    UIFont *font = [ELA getFont:15.0f];
    XLFormRowDescriptor * row;
    UIColor *labelColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1];
    
    XLFormSectionDescriptor * section = [XLFormSectionDescriptor formSectionWithTitle:@"Food Cost Control"];

    // Selector Push
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"netCost" rowType:XLFormRowDescriptorTypeInfo title:@"Net Cost"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [section addFormRow:row];
    
    // Selector Push
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"servingCost" rowType:XLFormRowDescriptorTypeInfo title:@"Net Cost Per Serving"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [section addFormRow:row];

    // Selector Push
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"servingCostPercentage" rowType:XLFormRowDescriptorTypeInfo title:@"Serving Cost %"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"servingProfit" rowType:XLFormRowDescriptorTypeInfo title:@"Serving Profit"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [section addFormRow:row];
    
    return section;
}

- (XLFormSectionDescriptor *) createSectionExpectedPortions
{
    UIFont *font = [ELA getFont:15.0f];
    XLFormRowDescriptor * row;
    
    XLFormSectionDescriptor * section = [XLFormSectionDescriptor formSectionWithTitle:@"Expected Yield"];
    
    UIColor *labelColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1];
    
    // Selector Push
    NSString *label = [ELA isMetric] ? @"Expected Loss (kg)" : @"Expected Loss (lbs)";
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"expectedLossWeight" rowType:XLFormRowDescriptorTypeInfo title:label];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    // Selector Push
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"expectedServings" rowType:XLFormRowDescriptorTypeInfo title:@"Number of Servings"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"expectedRevenue" rowType:XLFormRowDescriptorTypeInfo title:@"Expected Revenue"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"expectedProfit" rowType:XLFormRowDescriptorTypeInfo title:@"Expected Net Profit"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    return section;
}

- (XLFormSectionDescriptor *) createSectionActualYield
{
    XLFormRowDescriptor * row;
    UIFont *font = [ELA getFont:15.0f];
    UIColor *labelColor = [UIColor blackColor];
    
    XLFormSectionDescriptor * section = [XLFormSectionDescriptor formSectionWithTitle:@"Yield"];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"removedAt" rowType:XLFormRowDescriptorTypeDateInline title:@"Date Removed"];
    row.required = YES;
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [section addFormRow:row];
    
    NSString *label = [ELA isMetric] ? @"Actual End Weight (kg)" : @"Actual End Weight (lbs)";
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"weightEnd" rowType:XLFormRowDescriptorTypeNumber title:label];
    // @TODO FIX
    //row.cellReturnKeyType = UIReturnKeyNext;
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    row.required = NO;
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [section addFormRow:row];
    
    
    labelColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1];
    // Selector Push
    label = [ELA isMetric] ? @"Loss (kg)" : @"Loss (lbs)";
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"weightLoss" rowType:XLFormRowDescriptorTypeInfo title:label];
    [row.cellConfig setObject:labelColor forKey:@"textLabel.color"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [section addFormRow:row];
    
    return section;
}



- (void) updateSectionCalculations
{
    if (!self.isRemoving) {
        [self updateSectionFoodControl];
        [self updateSectionExpectedPortions];
    }
    if (!self.isAdding) {
        [self updateSectionActualPortions];
    }
}


- (float)getRowFloat: (NSString*)field
{
    XLFormRowDescriptor * row = [self.form formRowWithTag:field];
    return (row.value) ? [row.value floatValue] : 0;
}

- (float)getWeight
{
    return [self getRowFloat: @"weight"];
}
- (float)getCost
{
    return [self getRowFloat: @"cost"];
}
- (float)getCostTotal
{
    return [self getWeight] * [self getCost];
}
- (float)getCostNet
{
    float totalCost = [self getCostTotal];
    float expectedLoss = [self getExpectedLossPercent];
    return (totalCost * (1+expectedLoss));
}


- (float)getExpectedLossPercent
{
    float expectedLoss = [self getRowFloat: @"expectedLoss"];
    
    if (expectedLoss > 1.0) {
        expectedLoss = expectedLoss / 100.0f;
    }
    return expectedLoss;
}
- (float)getExpectedLossWeight
{
    float weight = [self getWeight];
    float expectedLoss = [self getExpectedLossPercent];
    return (weight > 0 && expectedLoss > 0) ? (weight * expectedLoss) : 0;
}

- (float)getServingSalePrice
{
    return [self getRowFloat: @"servingSalePrice"];
}

- (float)getServingCost
{
    float costTotal = [self getCostTotal];
    float expectedServings = [self getExpectedServings];
    return (expectedServings > 0) ? (costTotal / expectedServings) : 0;
}
- (float)getServingNetCost
{
    float costTotal = [self getCostNet];
    float expectedServings = [self getExpectedServings];
    return (expectedServings > 0) ? (costTotal / expectedServings) : 0;
}

- (float)getServingSize
{
    XLFormRowDescriptor * row = [self.form formRowWithTag:@"servingSize"];
    XLFormOptionsObject * val = (XLFormOptionsObject*)row.value;
    return (val != nil) ? [val.valueData floatValue] : 0;
}

- (float)getExpectedServings
{
    float endWeight = [self getWeight] - [self getExpectedLossWeight];
    float servingSize = [self getServingSize];
    
    if (endWeight > 0 && servingSize > 0) {
        if ([ELA isMetric]) {
            return (endWeight * 1000 / servingSize);
        }
        else {
            return (endWeight * 16 / servingSize);
        }
    }
    return 0;
}

- (NSString*)formatCurrency: (float) value
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:value]];
}


- (void) updateSectionFoodControl
{
    XLFormRowDescriptor * row;

    float servingSalePrice = [self getServingSalePrice];
    float servingCost = [self getServingCost];
    float costNet = [self getCostNet];
    float costNetServing = [self getServingNetCost];
    float servingCostPerc = (servingSalePrice > 0) ? (100 * (costNetServing / servingSalePrice)) : 0;
    float servingProfit = (servingSalePrice > 0 && costNetServing>0) ? servingSalePrice - costNetServing : 0;

    
    row = [self.form formRowWithTag:@"netCost"];
    row.value = (costNet != 0) ? [ELA formatCurrency: costNet] : @"";
    [self reloadFormRow:row];
    
    row = [self.form formRowWithTag:@"servingCost"];
    row.value = (costNetServing != 0) ? [ELA formatCurrency:costNetServing] : @"";
    [self reloadFormRow:row];
    
    row = [self.form formRowWithTag:@"servingCostPercentage"];
    row.value = (servingCostPerc != 0) ? [NSString stringWithFormat:@"%0.1f%%", servingCostPerc] : @"";
    [self reloadFormRow:row];
    
    row = [self.form formRowWithTag:@"servingProfit"];
    row.value = (servingProfit != 0) ? [ELA formatCurrency:servingProfit] : @"";
    [self reloadFormRow:row];
}
- (void) updateSectionExpectedPortions
{
    XLFormRowDescriptor * row;

    float servingSalePrice = [self getServingSalePrice];
    float expectedServings = [self getExpectedServings];
    
    float expectedLossWeight = [self getExpectedLossWeight];
    row = [self.form formRowWithTag:@"expectedLossWeight"];
    row.value = (expectedLossWeight >0) ? [NSString stringWithFormat:@"%0.1f", expectedLossWeight] : @"";
    [self reloadFormRow:row];
    
    row = [self.form formRowWithTag:@"expectedServings"];
    row.value = (expectedServings > 0) ? [NSString stringWithFormat:@"%0.1f", expectedServings] : @"";
    [self reloadFormRow:row];
    
    float expectedRevenue = servingSalePrice * expectedServings;
        
    row = [self.form formRowWithTag:@"expectedRevenue"];
    NSString *revenue = [self formatCurrency:expectedRevenue];
    row.value = revenue;
    [self reloadFormRow:row];
    
    float expectedProfit = expectedRevenue - [self getCostNet];
    row = [self.form formRowWithTag:@"expectedProfit"];
    row.value = [self formatCurrency:expectedProfit];
    [self reloadFormRow:row];

}


- (void) updateSectionActualPortions
{
    XLFormRowDescriptor * row;
    
    float weightStart = self.userObject.weight;
    float weightEnd   = [self getRowFloat:@"weightEnd"];
    
    float actualLossWeight = (weightStart>0 && weightEnd>0) ? weightStart-weightEnd : 0;
    row = [self.form formRowWithTag:@"weightLoss"];
    if (row != nil) {
        row.value = (actualLossWeight > 0) ? [NSString stringWithFormat:@"%0.1f", actualLossWeight] : @"";
        [self reloadFormRow:row];
    }
}


- (void) initMeatCuts: (NSString*)agingType
{
    XLFormOptionsObject *option;
    NSMutableArray *cutOptions = [[NSMutableArray alloc] init];
    
    [cutOptions addObject:[XLFormOptionsObject formOptionsObjectWithValue:@"other" displayText:@"Custom"]];
    
    BOOL isCharcuterie = [agingType isEqualToString:TYPE_CHARCUTERIE];
    BOOL add = NO;

    RLMResults * cuts = [Object getAll];
    
    for (Object *cut in cuts) {
        add = NO;
        if (isCharcuterie) {
            add = [cut.type isEqualToString:TYPE_CHARCUTERIE];
        }
        else {
            add = [cut.type isEqualToString:TYPE_DRYAGING_MEAT];
            if ([ELA isProUser] && [cut.type isEqualToString:TYPE_DRYAGING_PRO]) {
                add = YES;
            }
        }
        
        if (add) {
            option = [XLFormOptionsObject formOptionsObjectWithValue:cut.objectId displayText:cut.title];
            [cutOptions addObject:option];
        }
    }
    
    rowCuts.selectorOptions = cutOptions;
}

- (IBAction)onCancel: (id)sender
{
    UIViewController *parent = self.presentingViewController;
    
    if (parent != nil) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [ELA loadStoryboard:self storyboard:@"Dashboard"];
    }
}

-(void)showErrorMsg:(NSString *)msg
{
    hudMsg = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hudMsg.mode = MBProgressHUDModeCustomView;
    hudMsg.labelText = msg;

    [hudMsg hide:YES afterDelay:2];
}

- (BOOL)doValidate: (NSDictionary*)values
{
    NSArray *errors = [self formValidationErrors];
    if (errors != nil && [errors count] > 0) {
        for (NSError *error in errors) {
            //[self showFormValidationError:error title:@"Oops"];
            [self showFormValidationError:error];
            break;
        }
        return NO;
    }
    return YES;
}


- (IBAction)onAdd: (id)sender
{
    NSDictionary * values = [self formValues];
    NSString *value = nil;

    if ([self doValidate:values]) {
        PFUser *user = [PFUser currentUser];
        
        PFObject *device = [ELA getUserDevice];

        UserObject * userObject = (self.userObject != nil) ? self.userObject : [UserObject createNew];
        
        RLMRealm *realm = [ParseRlmObject startSave];
        
        userObject.userObjectId = user.objectId;
        userObject.deviceObjectId = device.objectId;

        if (!self.isRemoving) {
            if (![ELA isEmpty:values[@"object"]]) {
                value = [values[@"object"] formValue];
                if (![value isEqualToString:@"other"]) {
                    userObject.objectObjectId = value;
                }
                else {
                    userObject.objectObjectId = nil;
                }
            }
            if (![ELA isEmpty:values[@"vendor"]]) {
                value = [values[@"vendor"] formValue];
                if (![value isEqualToString:@"other"]) {
                    userObject.vendorObjectId = value;
                }
                else {
                    if (![ELA isEmpty:values[@"customVendor"]]) {
                        userObject.customVendor = values[@"customVendor"];
                    }
                }
            }
            if (![ELA isEmpty:values[@"nickname"]]) {
                userObject.nickname = values[@"nickname"];
            }
            if (![ELA isEmpty:values[@"quality"]]) {
                userObject.quality = [values[@"quality"] formValue];
            }
            if (![ELA isEmpty:values[@"days"]]) {
                NSString *str = values[@"days"];
                userObject.days = [str longLongValue];
            }
            if (![ELA isEmpty:values[@"weight"]]) {
                userObject.weight = [values[@"weight"] floatValue];
            }
            if (![ELA isEmpty:values[@"cost"]]) {
                userObject.cost = [values[@"cost"] floatValue];
            }        

            
            if (![ELA isEmpty:values[@"servingSize"]]) {
                userObject.servingSize = [values[@"servingSize"] floatValue];
            }
            if (![ELA isEmpty:values[@"servingSalePrice"]]) {
                userObject.servingPrice = [values[@"servingSalePrice"] floatValue];
            }
            if (![ELA isEmpty:values[@"expectedLoss"]]) {
                userObject.expectedLoss = [values[@"expectedLoss"] floatValue];
            }

            
            userObject.startedAt = values[@"startedAt"];
        }
        
        if (!self.isAdding) {
            if (![ELA isEmpty:values[@"weightEnd"]]) {
                userObject.weightEnd = [values[@"weightEnd"] floatValue];
            }
            if (![ELA isEmpty:values[@"removedAt"]]) {
                userObject.removedAt = values[@"removedAt"];
            }
        }
        
        userObject.active = YES;
        [userObject initFinishedAt];
        
        [realm addOrUpdateObject: userObject];
        [ParseRlmObject commitSave:realm];
        
        
        
        [userObject syncToRemote:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        }];

        
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        
        if ([self.parent isKindOfClass:[ItemsController class]]) {
            ItemsController * parentCtl = (ItemsController*)self.parent;
            [parentCtl onItemAdded];
        }
        else if ([self.parent isKindOfClass:[ItemController class]]) {
            ItemController * parentCtl = (ItemController*)self.parent;
            [parentCtl onItemEdited];
        }
        else if ([self.parent isKindOfClass:[DashboardController class]]) {
            DashboardController * parentCtl = (DashboardController*)self.parent;
            [ELA loadStoryboard:parentCtl storyboard:@"Items"];
        }
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [self.view setBackgroundColor:[ELA getColorBGLight]];    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)endEditing:(XLFormRowDescriptor *)rowDescriptor;
{
    [self updateSectionCalculations];
}


-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    NSString *nextTag = nil;
    XLFormRowDescriptor *row;
    
    if([formRow.tag isEqualToString:@"object"]) {
        NSString *objectId = [newValue formValue];
        
        for (Object *cut in [Object getAll]) {
            if ([cut.objectId isEqualToString:objectId]) {
                self.selectedObject = cut;
                
                // only update if we are not editing
                if (self.userObject == nil) {
                    row = [self.form formRowWithTag:@"days"];
                    row.value = [NSString stringWithFormat:@"%d", cut.defaultDays];
                    
                    row = [self.form formRowWithTag:@"servingSize"];
                    float servingSize = cut.suggestedServingSize;
                    if ([ELA isMetric]) {
                        servingSize = [ELA ouncesToGrams:servingSize];
                    }
                    row.value = [NSString stringWithFormat:@"%.1f", servingSize];
                    
                    row = [self.form formRowWithTag:@"expectedLoss"];
                    row.value = [NSString stringWithFormat:@"%d", (int)cut.expectedLoss];
                    
                    [self.tableView reloadData];
                }
                
                [self updateSectionCalculations];
                
                break;
            }
        }
        
        UITableViewCell<XLFormDescriptorCell> *cell = [formRow cellForFormController:self];
        BOOL can = [cell canResignFirstResponder];
        if (can) {
            [cell resignFirstResponder];
        }

        XLFormRowDescriptor *row = [self.form formRowWithTag:@"nickname"];
        cell = [row cellForFormController:self];
        if ([cell isKindOfClass:[XLFormTextFieldCell class]]) {
            XLFormTextFieldCell * textCell = (XLFormTextFieldCell*)cell;
            [textCell.textField becomeFirstResponder];
        }
    }
    else if ([formRow.tag isEqualToString:@"vendor"]){
        NSString *objectId = [newValue formValue];
        UITableViewCell<XLFormDescriptorCell> *cell = [formRow cellForFormController:self];
        BOOL can = [cell canResignFirstResponder];
        if (can) {
            [cell resignFirstResponder];
        }
        nextTag = @"days";
        
        if ([objectId isEqualToString:@"other"]) {
            [self addCustomVendorRow];
            nextTag = @"customVendor";
        }

        XLFormRowDescriptor *row = [self.form formRowWithTag:nextTag];
        cell = [row cellForFormController:self];
        if ([cell isKindOfClass:[XLFormTextFieldCell class]]) {
            XLFormTextFieldCell * textCell = (XLFormTextFieldCell*)cell;
            [textCell.textField becomeFirstResponder];
        }
    }
    else if ([formRow.tag isEqualToString:@"alertsEnabled"]){

    }
}

- (void)addCustomVendorRow
{
    XLFormRowDescriptor * vendorRow = [self.form formRowWithTag:@"vendor"];
    XLFormRowDescriptor * newRow = nil;
    newRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"customVendor" rowType:XLFormRowDescriptorTypeName title:@"Custom Vendor"];
    // @TODO FIX
    //newRow.cellReturnKeyType = UIReturnKeyNext;
    [newRow.cellConfig setObject:[ELA getFont:15.0f] forKey:@"textLabel.font"];
    [self.form addFormRow:newRow afterRow:vendorRow];
}


#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hudWhat {
    
    if (hud) {
        // Remove HUD from screen when the HUD was hidded
        [hud removeFromSuperview];
        hud = nil;
    }
    if (hudMsg) {
        [hudMsg removeFromSuperview];
        hudMsg = nil;
    }
}

@end
