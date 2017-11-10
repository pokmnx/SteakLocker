//
//  AppDelegate.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "SLModels.h"
#import "ELA.h"
#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.emitter = [[NSObject alloc] init];
    
    // Version 2.0, with mLab
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"MEhfCXacMGU4wU9R7GNImyxP8766VJwCpnvE4ctI";
        configuration.clientKey = @"NGE75s9iaDzxoPC4ckKWIJssAbyaDMkKd6HBmTxf";
        configuration.server = @"https://steaklocker.herokuapp.com/parse";
    }]];
    
    // Version 1.4
    //[Parse setApplicationId:@"MEhfCXacMGU4wU9R7GNImyxP8766VJwCpnvE4ctI"
    //              clientKey:@"NGE75s9iaDzxoPC4ckKWIJssAbyaDMkKd6HBmTxf"];

    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    [FBSDKSettings setAppID:@"1264631443553156"];

    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    UIFont *navBarFont = [ELA getFont:17];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:navBarFont, NSFontAttributeName,
                                [UIColor blackColor], NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    NSDictionary *attrBarBtn = [NSDictionary dictionaryWithObjectsAndKeys:navBarFont, NSFontAttributeName, nil];
    [[UIBarButtonItem appearance] setTitleTextAttributes:attrBarBtn forState:UIControlStateNormal];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [[UINavigationBar appearance] setTintColor:[ELA getColorAccent]];
    
    [ELA saveInstallationUser];
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        
    }];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    BOOL shouldPerformAdditionalDelegateHandling = YES;
    
    [self registerNotification:application];
    
    if([[UIApplicationShortcutItem class] respondsToSelector:@selector(new)]){
        
        [self configDynamicShortcutItems];
        
        // If a shortcut was launched, display its information and take the appropriate action
        UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKeyedSubscript:UIApplicationLaunchOptionsShortcutItemKey];
        
        if(shortcutItem)
        {
            // When the app launch at first time, this block can not called.
            
            [self handleShortCutItem:shortcutItem];
            
            // This will block "performActionForShortcutItem:completionHandler" from being called.
            shouldPerformAdditionalDelegateHandling = NO;
            
            
        }else{
            // normal app launch process without quick action
            
            [self launchWithoutQuickAction];
            
        }
        
    }else{
        
        // Less than iOS9 or later
        
        [self launchWithoutQuickAction];
        
    }
    
    return shouldPerformAdditionalDelegateHandling;
}

-(void)registerNotification:(UIApplication *)application {
    [ELA registerNotifications];
}

-(void)launchWithoutQuickAction
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ViewController *vc = [storyboard instantiateInitialViewController];
    
    self.window.rootViewController = vc;
    
    [self.window makeKeyAndVisible];
    
}
/**
 *  @brief config dynamic shortcutItems
 *  @discussion after first launch, users can see dynamic shortcutItems
 */
- (void)configDynamicShortcutItems
{
    PFUser *user = [PFUser currentUser];
    
    // config image shortcut items
    // if you want to use custom image in app bundles, use iconWithTemplateImageName method
    UIApplicationShortcutIcon *shortcutAddItemIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeAdd];
    UIApplicationShortcutIcon *shortcutVideosIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypePlay];
    
    UIApplicationShortcutItem *shortcutAddItem = [[UIApplicationShortcutItem alloc]
                                                 initWithType:@"com.ela-lifestyle.winelocker.add-item"
                                                 localizedTitle:@"Add Item to Locker"
                                                 localizedSubtitle:nil
                                                 icon:shortcutAddItemIcon
                                                 userInfo:nil];
    
    UIApplicationShortcutItem *shortcutVideos = [[UIApplicationShortcutItem alloc]
                                                   initWithType:@"com.ela-lifestyle.winelocker.view-videos"
                                                   localizedTitle:@"View Videos"
                                                   localizedSubtitle:nil
                                                   icon:shortcutVideosIcon
                                                   userInfo:nil];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    if (user != nil) {
        if ([ELA getDeviceCount] > 0) {
            [items addObject:shortcutAddItem];
            [items addObject:shortcutVideos];
        }
        
    }
    
    
    
    // add the array to our app
    [UIApplication sharedApplication].shortcutItems = [[NSArray alloc] initWithArray:items];
}



- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    
    BOOL handledShortCutItem = [self handleShortCutItem:shortcutItem];
    
    completionHandler(handledShortCutItem);
}

/**
 *  @brief handle shortcut item depend on its type
 *
 *  @param shortcutItem shortcutItem  selected shortcut item with quick action.
 *
 *  @return return BOOL description
 */
- (BOOL)handleShortCutItem : (UIApplicationShortcutItem *)shortcutItem{
    
    BOOL handled = NO;
    
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
    
    NSString *shortcutVideo = [NSString stringWithFormat:@"%@.view-videos", bundleId];
    NSString *shortcutAddItem = [NSString stringWithFormat:@"%@.add-item", bundleId];

    if ([shortcutItem.type isEqualToString:shortcutVideo]) {
        handled = YES;
        self.window.rootViewController = [ELA initStoryboard:@"Videos"];
        [self.window makeKeyAndVisible];
    }
    else if ([shortcutItem.type isEqualToString:shortcutAddItem]) {
        handled = YES;
        self.window.rootViewController = [ELA initStoryboard:@"Object"];
        [self.window makeKeyAndVisible];
    }
    
    return handled;
}



- (BOOL)application:(UIApplication *)application
     openURL:(NSURL *)url
     sourceApplication:(NSString *)sourceApplication
     annotation:(id)annotation {
         return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                               openURL:url
                                                     sourceApplication:sourceApplication
                                                            annotation:annotation];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}


- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
	
	[[NSNotificationCenter defaultCenter]postNotificationName: @"NotificationsAuthorization" object:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.steaklocker.app" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"app" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"app.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (NSObject*)getEmitter
{
    return self.emitter;
}


@end
