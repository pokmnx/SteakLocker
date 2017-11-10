//
//  ProductTableView.m
//  Steak Locker
//
//  Created by Jared Ashlock on 10/21/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ProductTableView.h"
#import "ItemsController.h"
#import <Parse/Parse.h>
#import "ProductTableCell.h"
#import "ELA.h"
#import "SLModels.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface ProductTableView ()

@end

@implementation ProductTableView

@synthesize hud;


- (instancetype)initWithFrame:(CGRect)frame items: (RLMResults*) objects
{
    self = [super initWithFrame: frame];
    self.objects = objects;
    self.dataSource = self;
    self.delegate = self;
    
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.separatorColor = [UIColor colorWithRed:206.0f/255.0f green:206.0f/255.0f blue:206.0f/255.0f alpha:1.0f];
    [self setSeparatorInset: UIEdgeInsetsZero];
    [self setAllowsSelection: YES];
    // During startup (-viewDidLoad or in storyboard) do:
    self.allowsMultipleSelectionDuringEditing = NO;
    
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setBackgroundColor: [ELA getColorBGLight]];
    
    return self;
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    ProductTableCell *cell = (ProductTableCell*)[self cellForRowAtIndexPath:indexPath];
    return ![cell isBadAgingType];
}


- (void) deleteUserObject: (UserObject*)userObject indexPath: (NSIndexPath*) indexPath
{
    
    RLMRealm *realm = [ParseRlmObject startSave];
    userObject.active = NO;
    [ParseRlmObject commitSave:realm];
    
    [userObject syncToRemote:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
    }];
    
    PFObject* device = [ELA getUserDevice];
    self.objects = [UserObject getAllForDeviceId: device.objectId];
    [self reloadData];
    
}

- (void) deleteUserObjectByType: (NSString *)agingType
{
    NSArray *items = [ELA getLatestUserObjects];
    
    for (UserObject *userObject in items) {
        if (userObject != nil) {
            if ([[[userObject object] getAgingType] isEqualToString:agingType]) {
                // TODO FIX
                //[userObject deleteInBackground];
            }
        }

    }
    
    ItemsController *parent = (ItemsController *)self.parentController;
    
    [parent refreshObjects:^(BOOL success) {
        
    }];
    
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UserObject *userObject = (UserObject *)self.objects[indexPath.row];

        ProductTableView * table = (ProductTableView*)tableView;
        
        [table deleteUserObject:userObject indexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (NSInteger)numberOfSections
{
    return 1;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    CGRect scrn = [[UIScreen mainScreen] bounds];
    
    UILabel *header = [[UILabel alloc] initWithFrame: CGRectMake(15, 15, scrn.size.width-30, 30)];
    NSString *label = @"My Items";
    PFObject *device = [ELA getUserDevice];
    if (device != nil) {
        label = [device objectForKey:@"nickname"];
    }
    
    
    if (!self.activeItems) {
        label = [NSString stringWithFormat:@"%@ (Past)", label];
    }

    header.text = label;
    
    
    [header setTextColor: [ELA getColorAccent]];
    [header setFont: [ELA getFont: 22.0f]];

    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor: [ELA getColorBGLight]];
    [view addSubview: header];
	
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"userObject";
    ProductTableCell *cell = (ProductTableCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[ProductTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    UserObject *userObject = (UserObject *)self.objects[indexPath.row];
    Object *object = userObject.object;

    cell.mUserObject = userObject;

    [cell setBackgroundColor: [ELA getColorBGLight]];
    
    NSString *itemTitle = userObject.nickname;
    NSString *agingType = nil;
    if (object != nil) {
        agingType = [object getAgingType];
    }
    else {
        PFObject *device = [ELA getUserDevice];
        agingType = [ELA getDeviceAgingType:device];
    }
    if ([ELA isEmpty:itemTitle] && object != nil) {
        itemTitle = object.title;
    }
    cell.textLabel.text = itemTitle;
    
    if ([userObject isInLocker]) {
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%@  //  Day %d of %d", agingType, [userObject getCurrentDay], (int)[userObject getTotalDays]];
    }
    else {
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%@  //  Aged %d days", agingType, [userObject getDaysAged]];
    }

    
    UIImage* placeholder = [UIImage imageNamed:@"UserObjectDefault"];
    NSString *imageUrl = object.imageUrl;
    [cell.imageView sd_setImageWithURL: [NSURL URLWithString: imageUrl] placeholderImage:placeholder];

    if ([cell isBadAgingType]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductTableCell *cell = (ProductTableCell*)[self cellForRowAtIndexPath:indexPath];
    UserObject *userObject = (UserObject *)self.objects[indexPath.row];
    
    if ([cell isBadAgingType]) {
        [self showAgingTypeWarning: userObject];
    }
    else {
        UIViewController *view = self.parentController;
    
        [self deselectRowAtIndexPath:indexPath animated:YES];
        [view performSegueWithIdentifier:@"segueItem" sender:userObject];
    }
}


- (void)showAgingTypeWarning: (UserObject*)userObject
{
    PFConfig *config = [ELA getConfig];
 
    NSString *itemAgingType = [userObject.object getAgingType];
    NSString *message = config[@"invalidAgingTypeWarning"];
    NSString *agingType = [ELA getAgingType];
    
    message = [message stringByReplacingOccurrencesOfString:@"[type]" withString:agingType];
    message = [message stringByReplacingOccurrencesOfString:@"[item-type]" withString:itemAgingType];
    

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Item"
                message: message
                delegate:self
                cancelButtonTitle:@"Cancel"
                otherButtonTitles:
                    @"Delete Only This Item",
                    [@"Delete All [item-type] Items" stringByReplacingOccurrencesOfString:@"[item-type]" withString:itemAgingType],
                    nil];

    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    NSIndexPath * indexPath = [self indexPathForSelectedRow];
    UserObject *userObject = (UserObject *)self.objects[indexPath.row];
    
    [self deselectRowAtIndexPath:indexPath animated:NO];

    if (buttonIndex == 0) {
        // Do Nothing
    }
    else if([title isEqualToString:@"Delete Only This Item"]) {
        [self deleteUserObject:userObject indexPath:indexPath];
    }
    else {
        [self deleteUserObjectByType:[userObject.object getAgingType]];
    }

}



@end
