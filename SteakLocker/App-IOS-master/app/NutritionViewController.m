//
//  ViewController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import "NutritionViewController.h"
#import <Parse/Parse.h>
#import "XLForm.h"
#import "ELA.h"

@interface NutritionViewController ()

@end

@implementation NutritionViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
    
}

- (instancetype) initWithObject:(Object *)object
{
    self = [self init];
    self.object = object;
    [self initializeForm];
    return self;
}

-(void)initializeForm
{
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSString *label;
    Object *obj = self.object;
    
    form = [XLFormDescriptor formDescriptor];
    
    // First section
    NSString *title;
    if (obj != nil) {
        title = [NSString stringWithFormat:@"%@ Nutrition Information", obj[@"title"]];
    }
    else {
        title = @"Nutrition Information";
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:title];
    [form addFormSection:section];
    
    NSDictionary *nutritionItems = @{
                                     @"servingSize" : @"Serving Size",
                                     @"calories" : @"Calories",
                                     @"caloriesFromFat" : @"Calories from Fat",
                                     @"totalFat" : @"Total Fat",
                                     @"saturatedFat" : @"Saturated Fat",
                                     @"transFat" : @"Trans Fat",
                                     @"cholesterol" : @"Cholesterol",
                                     @"sodium" : @"Sodium",
                                     @"carbohydrates" : @"Carbohydrates",
                                     @"dietaryFiber" : @"Dietary Fiber",
                                     @"sugars" : @"Sugars",
                                     @"protein" : @"Protein",
                                     @"vitaminA" : @"Vitamin A",
                                     @"vitaminC" : @"Vitamin C",
                                     @"calcium" : @"Calcium",
                                     @"iron" : @"Iron"
                                     };
    
    NSArray *items = @[
                       @"servingSize",
                       @"calories",
                       @"caloriesFromFat",
                       @"totalFat",
                       @"saturatedFat",
                       @"transFat",
                       @"cholesterol",
                       @"sodium",
                       @"carbohydrates",
                       @"dietaryFiber",
                       @"sugars",
                       @"protein",
                       @"vitaminA",
                       @"vitaminC",
                       @"calcium",
                       @"iron",
                       ];
    
    int count = 0;
    for (NSString *key in items) {
        if (obj[key]) {
            label = [nutritionItems objectForKey:key];
            row = [XLFormRowDescriptor formRowDescriptorWithTag:key rowType:XLFormRowDescriptorTypeInfo];
            row.title = label;
            row.value = obj[key];
            [section addFormRow:row];
            count++;
        }
    }
    
    if (count == 0) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"none" rowType:XLFormRowDescriptorTypeInfo];
        if (obj == nil) {
            row.title = @"Not available for custom items.";
        }
        else {
            row.title = @"Not yet available.";
        }
        [section addFormRow:row];
    }
    
    self.form = form;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor  =[ELA getColorBGLight];
    self.view.backgroundColor = [ELA getColorBGLight];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
