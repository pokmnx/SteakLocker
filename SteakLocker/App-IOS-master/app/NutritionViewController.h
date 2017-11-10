//
//  ViewController.h
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "XLForm.h"
#import "SLModels.h"


@interface NutritionViewController : XLFormViewController

@property (nonatomic, strong) Object *object;

- (instancetype) initWithObject:(Object *)object;


@end

