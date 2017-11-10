//
//  MyDropdownMenuController.m
//  DropdownMenuDemo
//
//  Created by Nils Mattisson on 1/13/14.
//  Copyright (c) 2014 Nils Mattisson. All rights reserved.
//

#import "DropdownController.h"

@interface DropdownController ()

@end

@implementation DropdownController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.theMenu = [ELA initDropMenuAndAdd:self];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
