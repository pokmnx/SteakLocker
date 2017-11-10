//
//  ELA.m
//  app
//
//  Created by Jared Ashlock on 10/9/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELABase.h"
#import "SLModels.h"
#import "ELADevice.h"
#import "Reachability.h"
@import SystemConfiguration.CaptiveNetwork;

@import Charts;

static PFObject * _userDevice = nil;
static NSArray * _userDevices = nil;
static NSArray * _userObjects = nil;
static NSUserDefaults *_userDefaults = nil;

static ELADevice * elaDevice = nil;

static NSArray * _meatCuts = nil;
static NSArray * _tipsTricks = nil;

static NSNumberFormatter *currencyFormatter;

NSString *const TYPE_DRYAGING = @"Dry Aging";
NSString *const TYPE_DRYAGING_MEAT = @"meat";
NSString *const TYPE_DRYAGING_PRO = @"Pro";
NSString *const TYPE_CHARCUTERIE = @"Charcuterie";



@implementation ELA

dispatch_queue_t asyncQueue;


+ (dispatch_queue_t)getAsyncQueue {
    if (!asyncQueue) {
        asyncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return asyncQueue;
}


+ (BOOL)isEmpty: (id) thing
{
    return thing == nil
    || [thing isKindOfClass:[NSNull class]]
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

+ (void)registerNotifications
{
    UIApplication *app = [UIApplication sharedApplication];
    
    // Register for Push Notitications, if running iOS 8
    if ([app respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [app registerUserNotificationSettings:settings];
        [app registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [app registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                 UIRemoteNotificationTypeAlert |
                                                 UIRemoteNotificationTypeSound)];
    }
}


+(void)load {
    _userDevice = nil;
}

+ (void)setUserDevice: (PFObject*)device
{
    _userDevice = device;
    
    if (device != nil) {
        [self saveCurrentDeviceObjectId: device.objectId];
    }
    
}



+ (PFObject*)getUserDevice
{
    if (_userDevice == nil) {
        NSString *objectId = [ELA getSavedDeviceObjectId];
        PFObject *device = nil;
        if (objectId != nil) {
            device = [self getUserDeviceById:objectId];
        }
        if (device != nil) {
            [self setUserDevice:device];
        }
        else if ([self getDeviceCount] > 0) {
            [self setUserDevice: [_userDevices firstObject]];
        }
    }
    
    return _userDevice;
}

+ (PFObject*)getUserDeviceById: (NSString*)objectId
{
    PFObject *device = nil;
    if (_userDevices != nil) {
        for (PFObject *item in _userDevices) {
            if ([item.objectId isEqualToString:objectId]) {
                device = item;
                break;
            }
        }
    }
    return device;
}

+ (PFObject*)getUserDeviceByImpeeId: (NSString* _Nonnull)impeeId
{
    PFObject *device = nil;
    if (_userDevices != nil) {
        for (PFObject *item in _userDevices) {
            NSString *deviceImpeeId = [item objectForKey:@"impeeId"];
            if ([deviceImpeeId isEqualToString:impeeId]) {
                device = item;
                break;
            }
        }
    }
    return device;
}


+ (NSArray*)getUserDevices
{
    return _userDevices;
}
+ (int)getDeviceCount
{
    return (_userDevices != nil) ? (int)[_userDevices count] : 0;
}

+ (BOOL)isDeviceActive:(PFObject*)device
{
    PFObject * userDevice = [self getUserDevice];
    return (userDevice != nil && device != nil && [userDevice.objectId isEqualToString:device.objectId]);
}

+ (PFObject * _Nullable)updateUserDevice: (PFObject * _Nullable)device latestMeasurement:(PFObject * _Nullable)measurement
{
    if (device && measurement) {
        [device setObject: measurement.createdAt forKey:@"lastMeasurementAt"];
        [device setObject: [measurement objectForKey:@"temperature"] forKey:@"lastTemperature"];
        [device setObject: [measurement objectForKey:@"humidity"] forKey:@"lastHumidity"];
    }
    return device;
}


+ (void) loadUserDevices:(void (^)(NSArray * objects, NSError * error))callback;
{
    if (_userDevices != nil && [_userDevices count] > 0) {
        callback(_userDevices, nil);
        return;
    }
    
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Device"];
    [query whereKey:@"user" equalTo:user];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            _userDevices = objects;
            
            [[ELA getApp] configDynamicShortcutItems];
        }
        callback(objects, error);
    }];
}

+ (void) reloadUserDevices:(void (^)(NSArray * objects, NSError * error))callback;
{
    _userDevices = nil;
    
    [self loadUserDevices:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        callback(objects, error);
    }];
}

+ (NSString*) getAgingType
{
    return [self getDeviceAgingType:[ELA getUserDevice]];
}


+ (NSString*) getDeviceAgingType: (PFObject*)device
{
    if (device != nil) {
        NSString *agingType = device[@"agingType"];
        if ([agingType isEqualToString:TYPE_CHARCUTERIE]) {
            return TYPE_CHARCUTERIE;
        }
    }
    return TYPE_DRYAGING;
}


+ (float) getDeviceTemperature: (PFObject *)device
{
    NSNumber *value = nil;
    if (device != nil) {
        value = device[@"settingTemperature"];
    }
    return [value floatValue];
}

+ (float) getDeviceHumidity: (PFObject*)device
{
    NSNumber *value = nil;
    if (device != nil) {
        value = device[@"settingHumidity"];
    }
    return [value floatValue];
}

+ (BOOL)userHasCharcuterieEnabled
{
    PFUser *user = [PFUser currentUser];
    BOOL enabled = [user[@"charcuterieEnabled"] boolValue];
    return enabled;
}

+ (void) userEnableCharcuterie
{
    PFUser *user = [PFUser currentUser];
    if (user != nil) {
        [user setObject:[NSNumber numberWithBool:YES] forKey:@"charcuterieEnabled"];
        [user saveInBackground];
    }
}

+ (void) userSetAgingType:(NSString*)agingType
{
    PFObject *device = [ELA getUserDevice];
    if (device != nil) {
        device[@"agingType"] = agingType;
        [device saveInBackground];
    }
}

+ (void) userSetTemperature: (float)fahrenheit
{
    PFObject *device = [ELA getUserDevice];
    if (device != nil) {
        device[@"settingTemperature"] = [NSNumber numberWithFloat:[self fahrenheitToCelsius: fahrenheit]];
        [device saveInBackground];
    }
}

+ (void) userSetHumidity: (float)humidity
{
    PFObject *device = [ELA getUserDevice];
    if (device != nil) {
        device[@"settingHumidity"] = [NSNumber numberWithFloat: humidity];
        [device saveInBackground];
    }
}

+ (void) deviceSetNickname:(PFObject*)device nickname:(NSString*)nickname
{
    if (device != nil) {
        device[@"nickname"] = nickname;
        [device saveInBackground];
    }
}


+ (void) deviceSetAgingType:(PFObject*)device agingType:(NSString*)agingType
{
    if (device != nil) {
        device[@"agingType"] = agingType;
        [device saveInBackground];
    }
}

+ (void) deviceSetTemperature:(PFObject*)device temp:(float)fahrenheit
{
    if (device != nil) {
        device[@"settingTemperature"] = [NSNumber numberWithFloat:[self fahrenheitToCelsius: fahrenheit]];
        [device saveInBackground];
    }
}

+ (void) deviceSetHumidity:(PFObject*)device humidity:(float)humidity
{
    if (device != nil) {
        device[@"settingHumidity"] = [NSNumber numberWithFloat: humidity];
        [device saveInBackground];
    }
}

+ (void) loadTipsTricks:(void (^)(BOOL, NSArray *))callback
{
    PFQuery *query = [SLTipTrick query];
    [query whereKey:@"active" equalTo: [NSNumber numberWithBool:YES]];
    [query whereKey:@"forAgingType" equalTo:[ELA getAgingType]];
    
    [query orderByAscending:@"rank"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        BOOL success = error ? false : true;
        if (success) {
            _tipsTricks = objects;
        }
        callback (success, objects);
    }];
}
+ (NSArray*)getTipsTricks
{
    return _tipsTricks;
}




+ (void) loadConfig:(void (^)(BOOL, PFConfig *))callback
{
    PFConfig *config = [PFConfig currentConfig];
    
    if (config != nil) {
        callback(true, config);
    }
    else {
        [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
            BOOL success = (error) ? false : true;
            callback(success, config);
            
        }];
    }
}
+ (PFConfig*)getConfig
{
    return [PFConfig currentConfig];
}

+(NSNumber*)getConfigNum: (NSString*)key
{
    PFConfig *config = [self getConfig];
    return (config != nil) ? config[key] : nil;
}

+ (int)getConfigInt: (NSString*)key
{
    NSNumber *value = [self getConfigNum:key];
    if (value != nil) {
        return [value intValue];
    }
    return 0;
}
+ (float)getConfigFloat: (NSString*)key
{
    NSNumber *value = [self getConfigNum:key];
    if (value != nil) {
        return [value floatValue];
    }
    return 0.0;
}
+ (BOOL)getConfigBool: (NSString*)key
{
    NSNumber *value = [self getConfigNum:key];
    if (value != nil) {
        BOOL b = [value boolValue];
        return b;
    }
    return NO;
}

+ (NSString *)getConfigString: (NSString*)key
{
    PFConfig *config = [self getConfig];
    NSString *value = (config != nil) ? [config objectForKey:key] : nil;
    return value;
}



+ (AppDelegate *) getApp
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (UIViewController *) getRootView
{
    return [[[self getApp] window] rootViewController];
}

+ (int)getStatusBarHeight
{
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

+ (NSNumberFormatter*)getCurrencyFormatter
{
    if (currencyFormatter == nil) {
        currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter setLocale:[NSLocale currentLocale]];
        [currencyFormatter setMaximumFractionDigits:2];
        [currencyFormatter setMinimumFractionDigits:2];
        [currencyFormatter setAlwaysShowsDecimalSeparator:YES];
        [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    }
    return currencyFormatter;
}

+ (NSString*)formatCurrency:(float)value
{
    return [[self getCurrencyFormatter] stringFromNumber:[NSNumber numberWithFloat:value]];
}

+ (float)gramsToOunces: (float)grams
{
    return grams * 0.03527396f;
}
+ (float)ouncesToGrams: (float)ounces
{
    return ounces / 0.03527396f;
}



+(int)getHeaderHeight: (UIViewController*)controller
{
    int height = [self getStatusBarHeight];
    
    if (controller.navigationController != nil) {
        height += controller.navigationController.navigationBar.frame.size.height;
    }
    if (controller.tabBarController != nil) {
        height += controller.tabBarController.tabBar.frame.size.height;
    }
    return height;
}

+ (int)getOffsetBottom: (UIViewController*)controller offset:(int)height
{
    return [ELA getScreen].size.height - [ELA getHeaderHeight:controller] - height;
    
}



+ (UIImageView *)addImage: (NSString*)file frame:(CGRect)frame
{
    UIImageView *image = [[UIImageView alloc] initWithFrame: frame];
    [image setImage:[UIImage imageNamed:file]];
    [image setContentMode:UIViewContentModeScaleAspectFit];
    return image;
}

+ (UIImageView *)addImage: (NSString*)file X:(int)x Y:(int)y W:(int)w H:(int)h
{
    return [self addImage:file frame:CGRectMake(x,y,w,h)];
}

+ (PFImageView *)addPFImage: (NSString*)file frame:(CGRect)frame
{
    PFImageView *image = [[PFImageView alloc] initWithFrame: frame];
    [image setImage:[UIImage imageNamed:file]];
    [image setContentMode:UIViewContentModeScaleAspectFit];
    return image;
}

+ (PFImageView *)addPFImage: (NSString*)file X:(int)x Y:(int)y W:(int)w H:(int)h
{
    return [self addPFImage:file frame:CGRectMake(x,y,w,h)];
}


+(CGRect)getScreen
{
    return [[UIScreen mainScreen] bounds];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+ (UIColor*)getColorText
{
    return [UIColor colorWithRed: 51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
}
+ (UIColor*)getColorBGDark
{
    return [UIColor colorWithRed: 51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    //    return [UIColor colorWithRed: 102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
}
+ (UIColor*)getColorBGDarker
{
    return [UIColor colorWithRed: 40.0f/255.0f green:40.0f/255.0f blue:40.0f/255.0f alpha:1.0f];
}
+ (UIColor*)getColorBGLight
{
    return [UIColor colorWithRed: 239.0f/255.0f green:239.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
}

+ (UIColor*)getColorBGLightest
{
    return [UIColor colorWithRed: 250.0f/255.0f green:250.0f/255.0f blue:250.0f/255.0f alpha:1.0f];
}
+ (UIColor*)getColorTypeWarning
{
    return [UIColor colorWithRed: 226.0f/255.0f green:90.0f/255.0f blue:90.0f/255.0f alpha:1.0f];
}


+ (UIFont*) getFont:(int)size
{
    return [UIFont systemFontOfSize: size];
}
+ (UIFont*) getFontThin:(int)size
{
    return [UIFont systemFontOfSize:size weight:UIFontWeightLight];
}
+ (UIFont*) getFontItalic:(int)size
{
    return [UIFont italicSystemFontOfSize:size];
}
+ (UIFont*) getFontMedium:(int)size
{
    return [UIFont systemFontOfSize:size weight:UIFontWeightRegular];
}
+ (UIFont*) getFontBold:(int)size
{
    return [UIFont systemFontOfSize:size weight:UIFontWeightHeavy];
}

+ (NSString *)getAPIKey
{
    return @"705968b5dacc03ff181386d9a474ffb6";
}

+ (NSString *)getGlobalPlanId
{
    return @"1a66a25bd8259841";
}


+ (void) saveDevice:(NSString *)impeeId planId:(NSString*)planId agentUrl:(NSString *)agentUrl callback:(void (^)())callback
{
    PFUser *user = [PFUser currentUser];
    user[@"planId"] = planId;
    user[@"impeeId"] = impeeId;
    [user saveEventually];
    
    PFObject *device = [PFObject objectWithClassName:@"Device"];
    device[@"type"] = @"steaklocker";
    device[@"impeeId"] = impeeId;
    device[@"planId"] = planId;
    device[@"agentUrl"] = agentUrl;
    device[@"user"] = user;
    device[@"agingType"] = TYPE_DRYAGING;
    
    [ELA setUserDevice:device];
    
    [device saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [ELA loadUserDevices:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                [ELA setUserDevice:device];
                
                callback();
            }];
        }
    }];
}


+ (void) getUserImpeeId:(void (^)(BOOL, NSString *))callback;
{
    PFObject *device = [ELA getUserDevice];
    if (device != nil) {
        NSString *impeeId = [device objectForKey: @"impeeId"];
        callback(impeeId != nil, impeeId);
    }
    else {
        [ELA loadUserDevices:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            PFObject *device = [ELA getUserDevice];
            NSString *impeeId = (device != nil) ? (NSString*)[device objectForKey: @"impeeId"] : nil;
            callback(impeeId != nil, impeeId);
        }];
    }
    
    
}

+ (void) getLatestMeasurement: (NSString*)impeeId  callback:(void (^)(BOOL, PFObject *))callback {
    PFQuery *query = [PFQuery queryWithClassName:@"Measurement"];
    [query whereKey:@"impeeId" equalTo:impeeId];
    [query orderByDescending:@"createdAt"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *measurement, NSError *error) {
        BOOL success = error ? false : true;
        callback(success, measurement);
    }];
}



+ (NSArray *) getLatestUserObjects
{
    return _userObjects;
}
+ (int) getCountLatestUserObjects: (NSString *)ignoreAgingType
{
    int count = 0;
    NSString *agingType;
    NSArray *items = [self getLatestUserObjects];
    
    for (UserObject *userObject in items) {
        agingType = [[userObject object] getAgingType];
        if (![agingType isEqualToString:ignoreAgingType]) {
            count ++;
        }
    }
    
    return count;
}


+ (UIImage*)blurredSnapshot: (UIView*)imageView frame: (CGRect)frame
{
    CGSize size = imageView.frame.size;
    return [ELA blurredSnapshot:imageView size:size frame:frame radius: 2.0f];
}

+ (UIImage*)blurredSnapshot: (UIView*)imageView size: (CGSize)size frame:(CGRect)frame radius:(float)radius
{
    UIGraphicsBeginImageContext(size);
    
    [imageView drawViewHierarchyInRect:imageView.frame afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([snapshotImage CGImage], frame);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    
    UIColor *tintColor = [UIColor colorWithWhite:0.2f alpha:0.2f];
    return [result applyBlurWithRadius:radius tintColor:tintColor saturationDeltaFactor:1.0f maskImage:nil];
}


+ (float)celsiusToFahrenheit:(float)celsius
{
    return ((celsius * 9.0f) / 5.0f) + 32.0f;
}
+ (float)celsiusToFahrenheit:(float)celsius round:(bool)round
{
    float value = [self celsiusToFahrenheit:celsius];
    return (float)(round ? lroundf(value) : value);
}
+ (float)fahrenheitToCelsius:(float)fahrenheit
{
    float val = (fahrenheit - 32.0f) / 1.8f;
    return val;
}


+ (DropMenu *)initDropMenu:(id)controller
{
    // Do any additional setup after loading the view.
    DropMenu *theMenu = [[DropMenu alloc] init];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    theMenu.frame = frame;
    theMenu.alpha = 0.0f;
    theMenu.parent = controller;
    
    
    return theMenu;
}

+ (DropMenu *)initDropMenuAndAdd:(id)controller
{
    UIViewController *viewController = (UIViewController*)controller;
    
    // Do any additional setup after loading the view.
    DropMenu *theMenu = [[DropMenu alloc] init];
    
    //CGRect frame = [[UIScreen mainScreen] bounds];
    CGRect frame = viewController.view.frame;
    
    theMenu.frame = frame;
    theMenu.alpha = 0.0f;
    theMenu.parent = controller;
    
    [self addDropMenu:theMenu controller:viewController];
    
    return theMenu;
}

+ (void)addDropMenu:(DropMenu*)theMenu controller:(id)controller
{
    UIViewController *viewController = (UIViewController*)controller;
    
    [viewController.view addSubview: theMenu];
    [viewController.view sendSubviewToBack: theMenu];
}


+ (NSUserDefaults*)getUserSettings
{
    if (_userDefaults == nil) {
        PFUser *user = [PFUser currentUser];
        if (user != nil) {
            _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:user.objectId];
        }
        else {
            _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"SteakLocker Anon"];
        }
    }
    return _userDefaults;
}

+ (BOOL)isUseFahrenheit
{
    BOOL useF = [[self getUserSettings] boolForKey:@"useFahrenheit"];
    return useF;
}
+ (void)setUseFahrenheit:(BOOL)value
{
    NSUserDefaults *userDefaults = [self getUserSettings];
    [userDefaults setBool:value forKey:@"useFahrenheit"];
    [userDefaults synchronize];
}

+ (BOOL)isMetric
{
    BOOL isMetric = [[self getUserSettings] boolForKey:@"useMetric"];
    return isMetric;
}
+ (void)setUseMetric:(BOOL)value
{
    NSUserDefaults *userDefaults = [self getUserSettings];
    [userDefaults setBool:value forKey:@"useMetric"];
    [userDefaults synchronize];
}




+ (void)saveCurrentDeviceObjectId:(NSString*)objectId
{
    NSUserDefaults *userDefaults = [self getUserSettings];
    [userDefaults setValue:objectId forKey:@"deviceId"];
    [userDefaults synchronize];
}

+ (NSString*)getSavedDeviceObjectId
{
    NSString *objectId = [[self getUserSettings] valueForKey:@"deviceId"];
    return objectId;
}

+ (BOOL)isAlertsEnabled
{
    BOOL value = [[self getUserSettings] boolForKey:@"alertsEnabled"];
    return value;
}
+ (void)setAlertsEnabled:(BOOL)value
{
    NSUserDefaults *userDefaults = [self getUserSettings];
    [userDefaults setBool:value forKey:@"alertsEnabled"];
    [userDefaults synchronize];
}

+ (void) setLastUpdated: (NSDate *) timeStamp {
	NSUserDefaults *userDefaults = [self getUserSettings];
	[userDefaults setObject:timeStamp forKey:@"lastUpdated"];
	[userDefaults synchronize];
}

+ (NSString *) getLastUpdated {
    PFObject *device = [ELA getUserDevice];
    NSDate * lastUpdatedTimestamp = (device != nil) ? [device objectForKey:@"lastMeasurementAt"] : nil;
    
	if (lastUpdatedTimestamp != nil) {
		return [self timeAgoStringFromDate:lastUpdatedTimestamp];
	}
	else {
		return nil;
	}
}

+ (BOOL) showConnectionWarning {
    PFObject *device = [ELA getUserDevice];
    NSDate * lastUpdatedTimestamp = (device != nil) ? [device objectForKey:@"lastMeasurementAt"] : nil;
    
	BOOL show = false;
	if (lastUpdatedTimestamp != Nil) {
		NSTimeInterval interval = [[NSDate date]timeIntervalSinceDate:lastUpdatedTimestamp];
		if (interval > 30 * 60) {
			show = true;
		}
	}
	return show;
}

+ (BOOL) showTempWarning {
    PFObject *device = [ELA getUserDevice];
    NSNumber *value = [device objectForKey:@"lastTemperature"];
    if (value == nil) {
        return false;
    }
    float lastTemp = [value floatValue];
    NSUserDefaults *userDefaults = [self getUserSettings];
    BOOL bStarted = [userDefaults boolForKey:@"warningTemp"];
    
    if (lastTemp > 7.22222) {
        [userDefaults setBool:true forKey:@"warningTemp"];
        if (bStarted == false) {
            
            NSDate * lastUpdatedTimestamp = (device != nil) ? [device objectForKey:@"lastMeasurementAt"] : nil;
            
            if (lastUpdatedTimestamp == nil)
                [userDefaults setObject:[NSDate date] forKey:@"warningStartTemp"];
            else
                [userDefaults setObject:lastUpdatedTimestamp forKey:@"warningStartTemp"];
            
            return false;
        }
        else {
            NSDate* startDate = [userDefaults objectForKey:@"warningStartTemp"];
            NSTimeInterval period = [[NSDate date] timeIntervalSinceDate:startDate];
            if (period > 60 * 60) {
                return true;
            }
            else
                return false;
        }
    }
    else {
        [userDefaults setBool:false forKey:@"warningTemp"];
        return false;
    }
}

+ (BOOL) showHumidityWarning {
    PFObject *device = [ELA getUserDevice];
    NSNumber *value = [device objectForKey:@"lastHumidity"];
    if (value == nil) {
        return false;
    }
    float lastTemp = [value floatValue];
    NSUserDefaults *userDefaults = [self getUserSettings];
    BOOL bStarted = [userDefaults boolForKey:@"warningHumidity"];
    
    if (lastTemp < 60) {
        [userDefaults setBool:true forKey:@"warningHumidity"];
        if (bStarted == false) {
            NSDate * lastUpdatedTimestamp = (device != nil) ? [device objectForKey:@"lastMeasurementAt"] : nil;
            
            if (lastUpdatedTimestamp == nil)
                [userDefaults setObject:[NSDate date] forKey:@"warningStartHum"];
            else
                [userDefaults setObject:lastUpdatedTimestamp forKey:@"warningStartHum"];
            
            return false;
        }
        else {
            NSDate* startDate = [userDefaults objectForKey:@"warningStartHum"];
            NSTimeInterval period = [[NSDate date] timeIntervalSinceDate:startDate];
            if (period > 60 * 60) {
                return true;
            }
            else
                return false;
        }
    }
    else {
        [userDefaults setBool:false forKey:@"warningHumidity"];
        return false;
    }
}

+ (NSString *)timeAgoStringFromDate:(NSDate *)date {
	NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
	formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
	
	NSDate *now = [NSDate date];
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond)
											   fromDate:date
												 toDate:now
												options:0];
	
	if (components.year > 0) {
		formatter.allowedUnits = NSCalendarUnitYear;
	} else if (components.month > 0) {
		formatter.allowedUnits = NSCalendarUnitMonth;
	} else if (components.weekOfMonth > 0) {
		formatter.allowedUnits = NSCalendarUnitWeekOfMonth;
	} else if (components.day > 0) {
		formatter.allowedUnits = NSCalendarUnitDay;
	} else if (components.hour > 0) {
		formatter.allowedUnits = NSCalendarUnitHour;
	} else if (components.minute > 0) {
		formatter.allowedUnits = NSCalendarUnitMinute;
	} else {
		formatter.allowedUnits = NSCalendarUnitSecond;
	}
	
	return [NSString stringWithFormat:@"%@ ago", [formatter stringFromDateComponents:components]];
}


+ (void)saveInstallationUser
{
    PFUser *user = [PFUser currentUser];
    if (user) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setObject:user forKey:@"user"];
        [currentInstallation saveEventually];
    }
}

+ (void)logOut: (UIViewController*) controller
{
    [PFUser logOut];
    
    _userDevice = nil;
    _userDevices = nil;
    _userObjects = nil;
    
    [[ELA getApp] configDynamicShortcutItems];
    
    [self onUserSet: NO];
    
    [ELA loadStoryboard:controller storyboard:@"Auth"];
}


+ (void) updateUserFromFacebook
{
    [self updateUserFromFacebook:nil];
}

+ (void) updateUserFromFacebook: (void (^)(BOOL))callback
{
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            PFUser *user = [PFUser currentUser];
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            [user setObject: userData[@"id"] forKey:@"facebookId"];
            [user setObject: userData[@"name"] forKey:@"name"];
            [user saveInBackground];
        }
        if (callback != nil) {
            callback(YES);
        }
    }];
}

+ (void)onSuccessfulLogin: (BOOL)newUser controller: (UIViewController *)context
{
    [ELA saveInstallationUser];
    
    [[ELA getApp] configDynamicShortcutItems];
    
    [self onUserSet: NO];
    
	[ELA loadUserDevices:^(NSArray * objects, NSError * error) {
		int count = [ELA getDeviceCount];
		if (count > 0) {
			[ELA loadStoryboard:context storyboard:@"Dashboard" animated:YES];
		}
		else {
			
			BOOL enabled = false;
			if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
			{
				enabled = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
			}
			else
			{
				UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
				enabled = types & UIRemoteNotificationTypeAlert;
			}
			
			if (enabled) {
				[ELA startAddNewDevice:context];
			}
			else {
                [ELA loadStoryboard:context storyboard:@"Notifications" animated:YES];
			}
		}
    }];
	
    [self syncStuff];
}

+ (void)onUserSet
{
    [self onUserSet: YES];
}

+ (void)onUserSet: (BOOL)sync
{
    [self setDefaultRealmForUser];
    if (sync) {
        [self syncStuff];
    }
}



+ (void)syncStuff
{
    if ([ELA hasInternet]) {
        [UserObject checkSync];
        [Object checkSync];
        [Vendor checkSync];
    }
}



+ (void)setDefaultRealmForUser
{
    PFUser *user = [PFUser currentUser];
    NSString *userId = (user != nil) ? user.objectId : @"anon";
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.deleteRealmIfMigrationNeeded = YES;
    config.schemaVersion = 3;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        if (oldSchemaVersion < 2) {
            // Nothing to do!
            // Realm will automatically detect new properties and removed properties
            // And will update the schema on disk automatically
        }
    };
    
    // Use the default directory, but replace the filename with the username
    config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent]
                       URLByAppendingPathComponent: userId]
                      URLByAppendingPathExtension:@"realm"];
    
    NSLog(@"Realm %@", config.fileURL);
    
    // Set this as the configuration used for the default Realm
    [RLMRealmConfiguration setDefaultConfiguration:config];
}



+ (void) supportEmail
{
    [ELA loadConfig:^(BOOL success, PFConfig* config){
        if (![ELA isEmpty:config[@"supportEmail"]]){
            NSString *url = [NSString stringWithFormat:@"mailto://%@",config[@"supportEmail"]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }];
}


+ (UIViewController *)initStoryboard: (NSString*)storyboard
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:storyboard bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:storyboard];
}

+ (void)loadStoryboard: (id)context storyboard:(NSString*)storyboard
{
    [self loadStoryboard:context storyboard:storyboard animated:YES];
}
+ (void)loadStoryboard: (id)context storyboard:(NSString*)storyboard animated:(BOOL)animated
{
    UIViewController *ctl = (UIViewController*)context;
    [ctl presentViewController:[self initStoryboard:storyboard] animated:animated completion:NULL];
}


+ (void)startAddNewDevice: (id _Nonnull )context
{
    [ELA loadStoryboard:context storyboard:@"SetupChooser" animated:YES];
}


+ (void)dismissStoryboard: (id)context
{
    [self dismissStoryboard:context animated:YES];
}
+ (void)dismissStoryboard: (id)context animated:(BOOL)animated
{
    UIViewController *ctl = (UIViewController*)context;
    [ctl dismissViewControllerAnimated:animated completion:^(void){
        
    }];
}




+ (void) on: (NSString*)event notify: (EventEmitterNotifyCallback)callback
{
    [[[self getApp] getEmitter] on:event notify:callback];
}

+ (void) on: (NSString*)event callback: (EventEmitterDefaultCallback)callback
{
    [[[self getApp] getEmitter] on:event callback: callback];
}

+ (void) emit: (NSString*)event
{
    [[[self getApp] getEmitter] emit:event];
}

+ (void) emit: (NSString*)event data: (id) arg0
{
    [[[self getApp] getEmitter] emit:event data:arg0];
}



+ (void)startNetworkActivity
{
    [[SDNetworkActivityIndicator sharedActivityIndicator] startActivity];
}
+ (void)stopNetworkActivity
{
    [[SDNetworkActivityIndicator sharedActivityIndicator] stopActivity];
}




+ (BOOL)isProUser
{
    PFUser *user = [PFUser currentUser];
    BOOL enabled = [user[@"isProUser"] boolValue];
    return enabled;
}


+ (NSDate*)getDaysAgoDate: (int)days
{
    NSDate *now = [NSDate date];
    
    // set up date components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay: 0-days];
    
    // create a calendar
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [gregorian dateByAddingComponents:components toDate:now options:0];
}

+ (NSInteger)getDaysAgo:(NSDate*)fromDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:[NSDate date]];
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    return [difference day];
}

+(int)getAxisX: (int)days date:(NSDate*)date
{
    NSInteger x = [self getDaysAgo:date];
    return ((int)(days - x));
}



+ (RLMResults *)getItems: (int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = nil;
    if (days > 0) {
        results = [UserObject getItemsAfterDate: [self getDaysAgoDate:days] object:objectId device:deviceId];
    }
    else {
        results = [UserObject getItemsAfterDateNoLimit: objectId device:deviceId];
    }
    return results;
}

+ (float)getAveragePricePerWeight:(int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = [self getItems: days object:objectId device:deviceId];
    
    float sum = 0;
    for (UserObject *userObject in results) {
        sum += [userObject getCost];
    }
    return sum / results.count;
}
+ (NSMutableArray*)getAveragePricePerWeightValues:(int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = [self getItems: days object:objectId device:deviceId];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSDate *date;
    
    for (UserObject *userObject in results) {
        date = (userObject.removedAt != nil) ? userObject.removedAt : userObject.finishedAt;
        if (date != nil) {
            int x = [self getAxisX:days date:date];
            [values addObject:[[ChartDataEntry alloc] initWithX: x y:[userObject getCost]]];
        }
    }
    return values;
}

+ (float)getAverageLossPercentage:(int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = [self getItems: days object:objectId device:deviceId];
    
    float sum = 0;
    for (UserObject *userObject in results) {
        sum += userObject.expectedLoss;
    }
    return sum / results.count;
}
+ (NSMutableArray*)getAverageLossPercentageValues:(int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = [self getItems: days object:objectId device:deviceId];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSDate *date;
    
    for (UserObject *userObject in results) {
        date = (userObject.removedAt != nil) ? userObject.removedAt : userObject.finishedAt;
        if (date != nil) {
            int x = [self getAxisX:days date:date];
            [values addObject:[[ChartDataEntry alloc] initWithX: x y:userObject.expectedLoss]];
        }
    }
    return values;
}


+ (float)getAverageActualLossPercentage:(int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = [self getItems: days object:objectId device:deviceId];
    
    float sum = 0;
    for (UserObject *userObject in results) {
        sum += [userObject getActualLoss];
    }
    return sum / results.count;
}
+ (NSMutableArray*)getAverageActualLossPercentageValues:(int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = [self getItems: days object:objectId device:deviceId];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSDate *date;
    
    for (UserObject *userObject in results) {
        date = (userObject.removedAt != nil) ? userObject.removedAt : userObject.finishedAt;
        if (date != nil) {
            int x = [self getAxisX:days date:date];
            [values addObject:[[ChartDataEntry alloc] initWithX: x y: [userObject getActualLoss]]];
        }
    }
    return values;
}



+ (float)getAverageServingSize:(int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = [self getItems: days object:objectId device:deviceId];
    
    float sum = 0;
    for (UserObject *userObject in results) {
        sum += [userObject getServingSize];
    }
    return sum / results.count;
}
+ (NSMutableArray*)getAverageServingSizeValues:(int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = [self getItems: days object:objectId device:deviceId];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSDate *date;
    
    for (UserObject *userObject in results) {
        date = (userObject.removedAt != nil) ? userObject.removedAt : userObject.finishedAt;
        if (date != nil) {
            int x = [self getAxisX:days date:date];
            [values addObject:[[ChartDataEntry alloc] initWithX: x y:[userObject getServingSize]]];
        }
    }
    return values;
}


+ (float)getAverageCostPercentage:(int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = [self getItems: days object:objectId device:deviceId];
    
    float sum = 0;
    for (UserObject *userObject in results) {
        float servingSalePrice = [userObject getServingSalePrice];
        float costNetServing = [userObject getServingNetCost];
        float servingCostPerc = (servingSalePrice > 0) ? (100 * (costNetServing / servingSalePrice)) : 0;
        sum += servingCostPerc;
    }
    return sum / results.count;
}
+ (NSMutableArray*)getAverageCostPercentageValues:(int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = [self getItems: days object:objectId device:deviceId];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSDate *date;
    
    for (UserObject *userObject in results) {
        date = (userObject.removedAt != nil) ? userObject.removedAt : userObject.finishedAt;
        if (date != nil) {
            int x = [self getAxisX:days date:date];
            
            float servingSalePrice = [userObject getServingSalePrice];
            float costNetServing = [userObject getServingNetCost];
            float servingCostPerc = (servingSalePrice > 0) ? (100 * (costNetServing / servingSalePrice)) : 0;
            
            [values addObject:[[ChartDataEntry alloc] initWithX: x y:servingCostPerc]];
        }
    }
    return values;
}


+ (float)getAverageSalePrice:(int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = [self getItems: days object:objectId device:deviceId];
    
    float sum = 0;
    for (UserObject *userObject in results) {
        float servingSalePrice = [userObject getServingSalePrice];
        sum += servingSalePrice;
    }
    return sum / results.count;
}
+ (NSMutableArray*)getAverageSalePriceValues:(int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = [self getItems: days object:objectId device:deviceId];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSDate *date;
    
    for (UserObject *userObject in results) {
        date = (userObject.removedAt != nil) ? userObject.removedAt : userObject.finishedAt;
        if (date != nil) {
            int x = [self getAxisX:days date:date];
            [values addObject:[[ChartDataEntry alloc] initWithX: x y:[userObject getServingSalePrice]]];
        }
    }
    return values;
}


+ (float)getAverageNetServingCost:(int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = [self getItems: days object:objectId device:deviceId];
    
    float sum = 0;
    for (UserObject *userObject in results) {
        float costNetServing = [userObject getServingNetCost];
        sum += costNetServing;
    }
    return sum / results.count;
}
+ (NSMutableArray*)getAverageNetServingCostValues:(int)days object:(NSString*)objectId device:(NSString* _Nullable)deviceId
{
    RLMResults *results = [self getItems: days object:objectId device:deviceId];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSDate *date;
    
    for (UserObject *userObject in results) {
        date = (userObject.removedAt != nil) ? userObject.removedAt : userObject.finishedAt;
        if (date != nil) {
            int x = [self getAxisX:days date:date];
            [values addObject:[[ChartDataEntry alloc] initWithX:x y:[userObject getServingNetCost]]];
        }
    }
    return values;
}


+ (NSString * _Nonnull)getPhoneId
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (ELADevice *)getElaDevice
{
    if (elaDevice == nil) {
        elaDevice = [ELADevice alloc];
    }
    return elaDevice;
}
+ (ELADevice *)resetElaDevice
{
    elaDevice = nil;
    return elaDevice;
}

+ (NSString*)getWifiSSID
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    NSString *ssid = nil;
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            ssid = [SSIDInfo valueForKey:@"SSID"];
            break;
        }
    }
    return ssid;
}

+(NSString *)currentWifiBSSID {
    
    NSString *bssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"BSSID"]) {
            bssid = info[@"BSSID"];
            break;
        }
    }
    return bssid;
}

+ (BOOL)hasInternet
{
    Reachability *networkReachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    BOOL hasInternet = NO;
    
    if (networkStatus != NotReachable) {
        ELADevice *elaDevice = [self getElaDevice];
        hasInternet = ![elaDevice isConnectedToDeviceWifi];
    }
    
    return hasInternet;
}

+ (void)openWifiSettings
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"prefs:root=WIFI"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=WIFI"]];
    }
}



@end;
